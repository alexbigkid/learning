#!/usr/bin/perl -w
##############################################################################
# author:           Alex Berger
# Copyright:        (C) @lex Berger
# Company:          http://www.abkphoto.com
# function:         this script will rename images, numerate them, move them
#                   into subdirectories.
#                   It will also convert proprietary raw files to dng and
#                   delete the original raw files after that if conversion
#                   went well.
# version:          V1.0 03/20/2016
# changed by:       Alex Berger
###############################################################################

use strict;
use warnings;
use POSIX ":sys_wait_h";
#use lib "$ENV{'HOME'}/lx/bin/lib";
# use lib "$ENV{'HOME'}/abkBin/Image";
# use lib "/Users/abk/dev/git/exif_rename";
use lib "$ENV{'HOME'}/.cpan/build/Image-ExifTool-10.55-xw9FL4/lib";
use lib "$ENV{'HOME'}/.cpan/build/Sys-Info-0.78-syy4di/lib";
use lib "$ENV{'HOME'}/.cpan/build/Sys-Info-Base-0.7804-4PBOoH/lib";
use lib "/usr/bin/lib";
use Image::ExifTool;
use Getopt::Std;
use Cwd;
use Cwd 'chdir';
#use File::Copy;
use File::Basename;
use File::Find;
use File::Path qw(remove_tree rmtree);
use Sys::Info;
use Sys::Info::Constants qw( :device_cpu );
use Data::Dumper;
#use YAML;
#use Win32::EventLog;
use constant false => 0;
use constant true  => 1;

#--------------------------------------------------------------------------
# variables definition
#--------------------------------------------------------------------------
my (
$abk_canon_mod,         # abk canon camera model modifications
$dir_pattern,           # directory pattern
$dng_converter,         # dng converter app
$dng_ext,               # dng extantion
%errors,                # error code
$files2exclude,         # files to exclude from search
$hash_ref,              # hash reference to the read structure
$hash_new_names,        # hash with new names
@img_ext,               # image extension name
%opts,                  # command line options
%os_env,                # OS type environment variables
@raw_ext,               # raw files extension
$raw_hash,              # reference to hash or raw directories
$sep_sign,              # separation sign
$shell_var,             # shell type
$this_file,             # the name of this file/ program
%thmb,                  # properties for thumbnail files
$version                # version
);


#--------------------------------------------------------------------------
# variables initialisation
#--------------------------------------------------------------------------
$abk_canon_mod = true;
$dir_pattern  = '^\d{8}_\w+';
$dng_converter = undef;
$dng_ext  = 'dng';
%errors       = (
  'chDir'     => 'cannot change to the directory',
  'format'    => 'does not have the expected format',
  'openDir'   => 'can not open the directory',
  'openFile'  => 'can not open the file:',
  'createFile'=> 'can not create the file:',
);
$files2exclude  = "Adobe Bridge Cache|Thumbs.db";
$hash_ref       = undef;
$hash_new_names = undef;
@img_ext   = ('avi', 'cr2', 'jpg', 'jpeg', 'tiff');
%opts = ();
%os_env    = (
  'win_env' => 'MSWin32',
  'mac_env' => 'darwin',
  'win_con' => 'C:\Program Files (x86)\Adobe\Adobe DNG Converter.exe',
  'mac_con' => '/Applications/Adobe DNG Converter.app/Contents/MacOS/Adobe DNG Converter',
  'MSWin32' => \&convert_to_dng_win,
  'darwin'  => \&convert_to_dng,
);
#@raw_ext  = ('cr2', 'dng');
# cr2 - RAW for Canon cameras
# 3fr - RAW for Hasselblad cameras
# sr2 - RAW for Sony cameras
# nef - RAW for Nikon cameras
#@raw_ext  = ('cr2', '3fr', 'sr2', 'nef');
@raw_ext  = ('cr2', 'nef');
$raw_hash = undef;
$sep_sign = '_';
$shell_var = $^O;
$this_file = basename($0, "");
%thmb      = (
  'ext'    => "jpg",
  'dir'    => "thmb",
);
$version   = "1.0";

#--------------------------------------------------------------------------
# setup
#--------------------------------------------------------------------------
# init command line parameters
getopts("htvd:", \%opts);

print STDOUT "\$^O = $^O\n" if(defined($opts{t}));
print STDOUT "\$shell_var = $shell_var\n" if(defined($opts{t}));

if($shell_var eq $os_env{'win_env'})
{
  $dng_converter = $os_env{'win_con'} if(-e -s $os_env{'win_con'});
  print STDOUT "Windows env: $os_env{'win_con'}\n" if(defined($opts{t}));
}
if($shell_var eq $os_env{'mac_env'})
{
  $dng_converter = $os_env{'mac_con'} if(-e -s $os_env{'mac_con'});
  print STDOUT "Mac OSX env: $os_env{'mac_con'}\n" if(defined($opts{t}));
}
else
{
  print STDOUT "Unknown environment\n" if(defined($opts{t}));
}

print STDOUT "\@ARGV  = ", scalar(@ARGV), "\n" if(defined($opts{t}));
print STDOUT "\$ARGV[0] = $ARGV[0]\n" if(defined($ARGV[0]) && defined($opts{t}));
print STDOUT "\$this_file = $this_file\n" if(defined($this_file) && defined($opts{t}));
print STDOUT "\$opts{h} = $opts{h}\n" if(defined($opts{h}) && defined($opts{t}));
print STDOUT "\$opts{t} = $opts{t}\n" if(defined($opts{t}));
print STDOUT "\$opts{v} = $opts{v}\n" if(defined($opts{v}) && defined($opts{t}));
print STDOUT "\$opts{d} = $opts{d}\n" if(defined($opts{d}) && defined($opts{t}));

die "$this_file version: $version\n(c) \@lex Berger\n"
  if(@ARGV!=0 ||
    (defined($opts{v}) && $opts{v} == 1));

die "\n$this_file - renames and moves image files to a directory manufacturer_model_extension. \
\
usage: $this_file \
-h             - help, this screen \
-t             - prints test output, for debugging/testing \
-v             - prints version \
-d <dir  name> - directory name, default is \".\" \n"
  if(@ARGV!=0 ||
    (defined($opts{h}) && $opts{h} == 1));


#-------------------------------------------------------------------------------
# Sub functions prototypes
#-------------------------------------------------------------------------------
sub read_dir ( );
sub move_and_rename_files ( $$ );
sub read_raw_dirs ( );
sub convert_to_dng ( $ );
sub process_pids ( $$$ );
sub delete_raw_dirs ( $ );
sub convert_to_dng_task( $$ );
sub convert_to_dng_win( $ );


#=============================================================================
# main program
#=============================================================================
# if the directory was not defined
my ($curDir) = (!defined($opts{d}) || $opts{d} eq '.' || $opts{d} eq './') ? '.' : cwd();

print STDOUT "[MAIN] \$curDir = $curDir\n" if(defined($opts{t}));

# change to the directory if required
if($curDir ne '.')
{
  chdir "$opts{d}" or die "cannot change to directory $opts{d}: $!\n";
  print STDOUT "[MAIN] current directory = $ENV{PWD}\n" if(defined($opts{t}));
}


#--------------------------------------------------------------------------
# read file names in the directory
#--------------------------------------------------------------------------
($hash_ref, $hash_new_names) = read_dir();

#--------------------------------------------------------------------------
# check whether there is something to go through
#--------------------------------------------------------------------------
if(defined($hash_ref))
{
  print STDOUT "[MAIN] \$hash_ref = $hash_ref, \$hash_new_names = $hash_new_names\n" if(defined($opts{t}));
  #------------------------------------------------------------------------
  # create the directories after the manufacturer_model_type
  #-----------------------------------------------------------------------
  move_and_rename_files($hash_ref, $hash_new_names);

  #------------------------------------------------------------------------
  # check for dng converter availability
  # convert to DNG format if we can and delete original raw files
  #-----------------------------------------------------------------------
  if(defined($dng_converter))
  {
    print STDOUT "[MAIN] dng_converter available\n" if(defined($opts{t}));

    # read original directory with RAW files
    $raw_hash = read_raw_dirs ( );
    # convert to dng and if successful delete the original raw directory
    print STDOUT "[MAIN] \$raw_hash = $raw_hash\n" if(defined($opts{t}));

    # check for the error condition If the raw hash has been defined
    # from the previous function call
    if(defined($raw_hash))
    {
      # depending on the environment a different function call will be called
      # windows env does not cope well with fork, wait, waitpid
      # so the dng conversion is slower
      if ( ($os_env{$shell_var})->( $raw_hash ) )
      {
        delete_raw_dirs ( $raw_hash );
      }
      else
      {
        print STDOUT "[MAIN] convert_to_dng delivered false!\n";
      }
    }
  }
}
else
{
  print STDOUT "[MAIN] Nothing to update: \$dir_content undefined or empty\n";
}

#--------------------------------------------------------------------------
# change back to directory where we were
#--------------------------------------------------------------------------
if($curDir ne '.')
{
  chdir "$curDir" or die "cannot change to directory $curDir: $!\n";
  print STDOUT "current directory = $ENV{PWD}\n" if(defined($opts{t}));
}


################################################################################
# Name :          read_dir
################################################################################
# function:       reads directory content
################################################################################
sub read_dir ( )
{
  my
  (
    @array_tmp,
    $create_date,
    $cur_dir,
    $day,
    $file,
    @file_names,
    @exif_tags,
    $make,
    $model,
    $month,
    %ret_hash,
    %ret_hash_names
  );
  print STDOUT "-> [READ_DIR]\n" if(defined($opts{t}));

  @array_tmp  = ();
  $create_date = 'CreateDate';
  $cur_dir    = basename(cwd());
  @file_names = ();
  $make       = 'Make';
  $model      = 'Model';

  #-----------------------------------------------------------------------------
  # check current directory name
  #-----------------------------------------------------------------------------
  $cur_dir =~ /^\d{4}(\d{2})(\d{2})_\w+$/;
  $month = $1;
  $day   = $2;

  die "wrong month $month\n" if(defined($month) && $month > 12);
  die "wrong day $day\n" if(defined($day) && $day > 31);

  #-----------------------------------------------------------------------------
  # read theme directories
  #-----------------------------------------------------------------------------
  opendir(CUR_DIR, ".") or die "$errors{openDir} $ENV{PWD}: $!\n";
#  @array_tmp = sort grep /^\w+$/, grep -d, readdir CUR_DIR;
#  rewinddir CUR_DIR;
  # sort exclude all files wh . in front of it, read only files
  @file_names = sort grep !/^\./, grep !/$files2exclude/, grep -f, readdir CUR_DIR;
  closedir(CUR_DIR);

  # read the file names and build up a structure
  foreach $file (@file_names)
  {
    my ($dir_name, $file_exif, $file_ext, $file_info, $file_base);
    # get file extension
    lc($file) =~ /\.(\w+)$/;
    $file_base = $`;
    $file_ext  = $1;
    print STDOUT "[READ_DIRS] \$file_base = $file_base, \$file_ext = $file_ext \n" if(defined($opts{t}) && defined($file_ext));

    # check if it is a thumbnail from a raw file
    if($file_ext eq $thmb{'ext'})
    {
      foreach(@raw_ext)
      {
        $file_ext = $thmb{'dir'} if(-f "$file_base.$_")
      }
    }
    $file_exif = new Image::ExifTool;
    $file_exif->Options(DateFormat => '%Y%m%d_%H%M%S');

    @array_tmp  = ($make, $model, $create_date);
    $file_info = $file_exif->ImageInfo($file);
    $file_info = $file_exif->GetInfo($file, \@array_tmp);

    print STDOUT "[READ_DIRS] \$file = $file, \$file_ext = $file_ext \n" if(defined($opts{t}) && defined($file_ext));
#    printf("%-24s : %s\n", $make, $$file_info{$make});
#    printf("%-24s : %s\n", $model, $$file_info{$model});
#    printf("%-24s : %s\n", $create_date, $$file_info{$create_date});

    # modify make to just 1 word
    if(defined($$file_info{$make}))
    {
      @array_tmp = split /\s+/, $$file_info{$make};
      $$file_info{$make} = lc(shift @array_tmp);
    }
    else
    {
      $$file_info{$make} = 'unknown';
    }

    # modify model to just 1 word
    if(defined($$file_info{$model}))
    {
      @array_tmp = split /\s+/, $$file_info{$model};
      # if the make is the same as the first word in the model strip it

      if($$file_info{$make} eq lc($array_tmp[0]))
      {
        shift @array_tmp;
        # strip eos
        if($abk_canon_mod)
        {
          if(defined($array_tmp[1]) && lc($array_tmp[0]) eq 'eos')
          {
            shift @array_tmp;
          }
          if(defined($array_tmp[0]) && lc(join '_', @array_tmp) eq '5d_mark_ii')
          {
            undef(@array_tmp);
            push(@array_tmp, '5dm2');
          }
        }
      }
      $$file_info{$model} = lc(join '', @array_tmp);
      @array_tmp = split /,/, $$file_info{$model};
      $$file_info{$model} = shift @array_tmp;
    }
    else
    {
      $$file_info{$model} = 'unknown';
    }

    $dir_name = join '_', $$file_info{$make}, $$file_info{$model}, $file_ext;

    push @{$ret_hash{$dir_name}}, $file;
    push @{$ret_hash_names{$dir_name}}, $$file_info{$create_date};
  }

  print STDOUT "[READ_DIRS] \$ret_hash =\n", Dumper \%ret_hash, "\n\n" if(defined($opts{t}));
  print STDOUT "[READ_DIRS] \$ret_hash_names =\n", Dumper \%ret_hash_names, "\n\n" if(defined($opts{t}));

  print STDOUT "<- [READ_DIR]\n" if(defined($opts{t}));
  return \%ret_hash, \%ret_hash_names;
}


################################################################################
# Name :          move_and_rename_files
################################################################################
# function:       creates directory structure and moves the files
################################################################################
sub move_and_rename_files ( $$ )
{
  my ($dir_hash, $file_hash) = @_;
  my $i;
  my $event_name;
  my @array_tmp;
  my $date_backup;
  my $cam_model;
  print STDOUT "-> [MOVE_AND_RENAME_FILES]\n" if(defined($opts{t}));

  print STDOUT "[MOVE_AND_RENAME_FILES] \$dir_hash = $dir_hash, \$file_hash = $file_hash\n" if(defined($opts{t}));

  # get the last part of directory
  $event_name = lc(basename(cwd()));
  # print STDOUT "1 [MOVE_AND_RENAME_FILES] \$event_name = $event_name\n" if(defined($opts{t}));
  @array_tmp = split $sep_sign, $event_name;
  $date_backup = shift @array_tmp;
  # print STDOUT "2[MOVE_AND_RENAME_FILES] \$date_backup = $date_backup\n" if(defined($opts{t}));
  $event_name = join $sep_sign, @array_tmp;
  # print STDOUT "[MOVE_AND_RENAME_FILES] dir = $event_name\n" if(defined($opts{t}));

  # create sub directory structure
  foreach(keys %{$dir_hash})
  {
    my $file_ext;

    lc(${$$dir_hash{$_}}[0]) =~ /\.(\w+)$/;
    $file_ext  = $1;

    mkdir $_, 0755 or die $! unless -d $_;
    print STDOUT "[MOVE_AND_RENAME_FILES] created directory: $_\n";
    for $i (0 .. $#{$$dir_hash{$_}})
    {
      my @dir_array=();
      @dir_array = split($sep_sign, $_);
      $cam_model = $dir_array[1];
#      print STDOUT "[MOVE_AND_RENAME_FILES] \$cam_model = $cam_model\n" if(defined($opts{t}));

#      print STDOUT "[MOVE_AND_RENAME_FILES] [$i]old_name: ${$$dir_hash{$_}}[$i]\n" if(defined($opts{t}));
      if(defined(${$$file_hash{$_}}[$i]) && (${$$file_hash{$_}}[$i] ne ""))
      {
        rename ${$$dir_hash{$_}}[$i], sprintf("$_/${$$file_hash{$_}}[$i]_$cam_model" ."_$event_name" . "_" . "%03d.$file_ext", $i+1);
#        print STDOUT sprintf("$_/${$$file_hash{$_}}[$i]_$event_name" . "_" . "%03d.$file_ext\n", $i+1) if(defined($opts{t}));
      }
      else
      {
        rename ${$$dir_hash{$_}}[$i], sprintf("$_/$date_backup" . "_$event_name" . "_" . "%03d.$file_ext", $i+1);
#        print STDOUT sprintf("$_/$date_backup" . "_" . "%03d.$file_ext\n", $i+1) if(defined($opts{t}));
      }
    }
  }
  print STDOUT "<- [MOVE_AND_RENAME_FILES]\n" if(defined($opts{t}));
}

################################################################################
# Name :          read_raw_dirs
################################################################################
# function:       reads directories with RAW files
################################################################################
sub read_raw_dirs ( )
{
  print STDOUT "-> [READ_RAW_DIRS]\n" if(defined($opts{t}));
  my %ret_hash;
  my @array_tmp;
  my $dir;


  opendir(CUR_DIR, ".") or die "$errors{openDir} $ENV{PWD}: $!\n";
  @array_tmp = sort grep /^\w+$/, grep -d, readdir CUR_DIR;
  closedir(CUR_DIR);

  # read the directory names and build up a structure
  foreach $dir (@array_tmp)
  {
    print STDOUT "[READ_RAW_DIRS] \$dir = $dir\n" if(defined($opts{t}));
    foreach(@raw_ext)
    {
      if($dir =~ /$_$/)
      {
        print STDOUT "[READ_RAW_DIRS] \$_ = $_, \$dir = $dir\n" if(defined($opts{t}));

        # change into the RAW file directory to read the files sizes also, to ignore 0 byte size files
		chdir "$dir" or die "[ERROR] cannot change to directory $dir: $!\n";
        # read file names of raw files
        opendir(RAW_DIR, ".") or die "$errors{openDir} $ENV{PWD}: $!\n";
        # sort exclude all files with . in front of it
        push @{$ret_hash{$dir}}, sort grep !/^\./, grep !/$files2exclude/, grep -s -f, readdir RAW_DIR;
        closedir(RAW_DIR);
        chdir ".." or die "[ERROR] cannot change to directory .. : $!\n";
      }
    }
  }

  print STDOUT "[READ_RAW_DIRS] \$ret_hash =\n", Dumper \%ret_hash, "\n\n" if(defined($opts{t}));

  print STDOUT "<- [READ_RAW_DIRS]\n" if(defined($opts{t}));
  return \%ret_hash;
}

################################################################################
# Name :          convert_to_dng
################################################################################
# function:       converts proprietary raw files to dng files
#                 returns 1 if all files converted successfully
################################################################################
sub convert_to_dng ( $ )
{
  my ($dng_hash) = @_;
  my ($dng_dir, $raw_dir, $max_kids, %work, @work, %pids, $ret_val, $res);
  my ($info, $info_cpu, $info_cpu_ht, %options);

  print STDOUT "-> [CONVERT_TO_DNG] \$dng_hash = $dng_hash\n" if(defined($opts{t}));
  $ret_val = true;

  $info = Sys::Info->new;
  $info_cpu  = $info->device( CPU => %options );

  printf STDOUT "[CONVERT_TO_DNG] CPU: %s\n", scalar($info_cpu->identify)  || 'N/A' if(defined($opts{t}));
  printf STDOUT "[CONVERT_TO_DNG] CPU speed is %s MHz\n", $info_cpu->speed || 'N/A' if(defined($opts{t}));
  printf STDOUT "[CONVERT_TO_DNG] There are %d CPUs\n"  , $info_cpu->count || 1 if(defined($opts{t}));
  printf STDOUT "[CONVERT_TO_DNG] Hyper threads %d\n"   , $info_cpu->ht    || 1 if(defined($opts{t}));
  printf STDOUT "[CONVERT_TO_DNG] CPU load: %s\n"       , $info_cpu->load  || 0 if(defined($opts{t}));
  $info_cpu_ht = $info_cpu->ht;
#  $info_cpu_ht = $info_cpu->count;

#  print OUTPUT Dumper(%{$raw_ref});

  # if there are more then 1 directory with raw files
  foreach ( keys %{$dng_hash} )
  {
    # replace last 3 characters with dng extension
    $raw_dir = $_;
    $dng_dir = $_;
    $dng_dir =~ s/\w{3}$/$dng_ext/;
    mkdir $dng_dir, 0755 or die $! unless -d $dng_dir;
    printf STDOUT "[CONVERT_TO_DNG] created directory: $dng_dir\n";

    # if number of files to convert > then number of available threads
    $max_kids = ( $info_cpu_ht > $#{$$dng_hash{$_}} ) ? $#{$$dng_hash{$_}} + 1 : $info_cpu_ht;

    print STDOUT "[CONVERT_TO_DNG] \$max_kids = $max_kids\n" if(defined($opts{t}));

    %work = map { $_ => 1 } 1 .. ($#{$$dng_hash{$_}} + 1);
    @work = sort {$a <=> $b} keys %work;

    # loop over number of raw files
    while (@work)
    {
      my $work = shift @work;
      my $pid = undef;

      print STDOUT "[CONVERT_TO_DNG] \$work = $work\n" if(defined($opts{t}));
      print STDOUT "[CONVERT_TO_DNG] \@work = @work\n" if(defined($opts{t}));
      die "[CONVERT_TO_DNG] could not fork" unless defined($pid = fork());

      if ($pid)
      {
        # parent running
        $pids{$pid} = 1;
        print STDOUT "[CONVERT_TO_DNG] $$ parent \$pid = $pid, \$work = $work\n" if(defined($opts{t}));
        # proceed to the next file if there is still a slot available
        # otherwise the loop will wait at the wait condition below
        $res = waitpid $pid, WNOHANG;
        next if (keys %pids < $max_kids and @work);
      }
      else
      {
       # child running
        print STDOUT "[CONVERT_TO_DNG] $$ kid executing $work\n" if(defined($opts{t}));
        if(defined(${$$dng_hash{$_}}[$work-1]) && (${$$dng_hash{$_}}[$work-1] ne ""))
        {
          $ret_val = convert_to_dng_task( $dng_dir, "$raw_dir/${$$dng_hash{$_}}[$work-1]" );
        }
        print STDOUT "[CONVERT_TO_DNG] $$ kid done $work\n" if(defined($opts{t}));
        ($ret_val) ? exit $work : exit 0;
      }
      print "[CONVERT_TO_DNG] $$ waiting\n" if(defined($opts{t}));;
      $res = wait;
#      my $res = waitpid $pid, 0;
#      my $res = waitpid -1, WNOHANG;
      print "[CONVERT_TO_DNG] $$ \$res = $res\n" if(defined($opts{t}));;

      process_pids( \%pids, \%work, $res );
      select undef, undef, undef, .25;
    }

    # wait until all child processes are complete
    while(($res=wait) != -1)
    {
      process_pids( \%pids, \%work, $res );
    }
  }
  print STDOUT "<- [CONVERT_TO_DNG]\n" if(defined($opts{t}));
  return $ret_val;
}

################################################################################
# Name :          process_pids
################################################################################
# function:       processes pids of working kids
################################################################################
sub process_pids ( $$$ )
{
  my ( $pids, $work, $res ) = @_;
  print STDOUT "-> [PROCESS_PIDS] $pids, $work, $res\n" if(defined($opts{t}));

  print STDOUT "[PROCESS_PIDS] \$res = $res \n" if(defined($opts{t}));

  if ($res > 0)
  {
    delete $$pids{$res};
    my $rc = $? >> 8; #get the exit status
    print STDOUT "[PROCESS_PIDS] $$ saw $res was done with $rc\n" if(defined($opts{t}));
    delete $$work{$rc};
    print STDOUT "[PROCESS_PIDS] $$ work left: ", join(", ", sort {$a <=> $b} keys %{$work}), "\n" if(defined($opts{t}));
  }
  else
  {
    print STDOUT "[PROCESS_PIDS] $$ wait returned < 0, FAIL\n" if(defined($opts{t}));
  }
  print STDOUT "<- [PROCESS_PIDS]\n" if(defined($opts{t}));
}

################################################################################
# Name :          delete_raw_dirs
################################################################################
# function:       deletes proprietary raw files
################################################################################
sub delete_raw_dirs ( $ )
{
  my ($dng_hash) = @_;
  my ($dng_dir, $raw_dir) = undef, undef;
  my ($raw_file, $dng_file) = undef, undef;
  my $ret_val = true;

  print STDOUT "-> [DELETE_RAW_DIRS]\n" if(defined($opts{t}));

  # check whether all original raw files has been converted
  # if there are more then 1 directory with raw files
  foreach ( keys %{$dng_hash} )
  {
    my @file_names;
    # replace last 3 characters with dng extension
    $raw_dir = $_;
    $dng_dir = $_;
    $dng_dir =~ s/\w{3}$/$dng_ext/;

    print STDOUT "[DELETE_RAW_DIRS] \$dng_dir       = $dng_dir\n" if(defined($opts{t}));
    print STDOUT "[DELETE_RAW_DIRS] \$raw_dir       = $raw_dir\n" if(defined($opts{t}));

    # change to the dng directory, otherwise we won't get the file size
    chdir "$dng_dir" or die "cannot change to directory $dng_dir: $!\n";
    opendir(DNG_DIR, ".") or die "$errors{openDir} $ENV{PWD}: $!\n";
    # sort exclude all files with . in front of it and 0 byte files
    push @file_names, sort grep !/^\./, grep !/$files2exclude/, grep -s -f, readdir DNG_DIR;
    closedir(DNG_DIR);
    # change back to the original directory
    chdir ".." or die "cannot change to directory .. : $!\n";

    print STDOUT "[DELETE_RAW_DIRS] \$#file_names       = $#file_names\n" if(defined($opts{t}));
    print STDOUT "[DELETE_RAW_DIRS] \$#{$$dng_hash{$_}} = $#{$$dng_hash{$_}}\n" if(defined($opts{t}));
    print STDOUT "[DELETE_RAW_DIRS] \@file_names = @file_names\n" if(defined($opts{t}));


    if ( $#file_names == $#{$$dng_hash{$_}} )
    {
      for my $i (0 .. $#file_names)
      {
#        print STDOUT "[DELETE_RAW_DIRS] \$file_names[$i]         = $file_names[$i]\n" if(defined($opts{t}));
#        print STDOUT "[DELETE_RAW_DIRS] \${$$dng_hash{$_}}[$i] = ${$$dng_hash{$_}}[$i]\n" if(defined($opts{t}));

        $raw_file = basename(${$$dng_hash{$_}}[$i], @raw_ext);
        $dng_file = basename($file_names[$i], $dng_ext);
        print STDOUT "[DELETE_RAW_DIRS] \$raw_file = $raw_file\n" if(defined($opts{t}));
        print STDOUT "[DELETE_RAW_DIRS] \$dng_file = $dng_file\n" if(defined($opts{t}));

        if($raw_file ne $dng_file)
        {
          $ret_val = false;
          print STDOUT "[DELETE_RAW_DIRS] didn't delete $raw_dir, file names didn't macth\n";
          print STDOUT "[DELETE_RAW_DIRS] \$raw_file != \$dng_file\n" if(defined($opts{t}));
          print STDOUT "[DELETE_RAW_DIRS] $raw_file != $dng_file\n" if(defined($opts{t}));
          last;
        }
      }
    }
    else
    {
      $ret_val = false;
      print STDOUT "[DELETE_RAW_DIRS] didn't delete $raw_dir, number of converted files mismatch\n";
    }

    if($ret_val)
    {
      print STDOUT "[DELETE_RAW_DIRS] deleting dir: $raw_dir\n";
      $ret_val = false if (!rmtree($raw_dir, 0, 1));
    }
    else
    {
      print STDOUT "[DELETE_RAW_DIRS] not deleting dir: $raw_dir\n";
    }

  }
  print STDOUT "<- [DELETE_RAW_DIRS]\n" if(defined($opts{t}));
  return $ret_val;
}

################################################################################
# Name :          convert_to_dng_task
################################################################################
# function:       converts proprietary raw files to dng files
################################################################################
sub convert_to_dng_task( $$ )
{
  my ($d_dng, $f_dng) = @_;
  my $ret_val = true;
  my @cmd_param;

  print STDOUT "-> [CONVERT_TO_DNG_TASK] $$ \$d_dng = $d_dng, \$f_dng = $f_dng\n" if(defined($opts{t}));

  push @cmd_param, "$dng_converter";
  push @cmd_param, "-c -p1 -n";
  push @cmd_param, "-d";
  push @cmd_param, $d_dng;
  push @cmd_param, $f_dng;
  print STDOUT "[CONVERT_TO_DNG_TASK] $$ @cmd_param\n" if(defined($opts{t}));
  system ( @cmd_param );

  if( $? == -1 )
  {
    print STDOUT "[CONVERT_TO_DNG_TASK] $$ dng conversion failed: $!\n" if(defined($opts{t}));
    $ret_val = false;
  }
  else
  {
    printf STDOUT "[CONVERT_TO_DNG_TASK] $$ dng conversion exited with value %d\n", $? >> 8 if(defined($opts{t}));
  }
  print STDOUT "<- [CONVERT_TO_DNG_TASK] $$\n" if(defined($opts{t}));
  return $ret_val;
}

################################################################################
# Name :          convert_to_dng_win
################################################################################
# function:       converts proprietary raw files to dng files
#                 returns true if all files converted successfully
################################################################################
sub convert_to_dng_win( $ )
{
  my ($dng_hash) = @_;
  my ($dng_dir, $raw_dir, %work, @work, $ret_val);

  print STDOUT "-> [CONVERT_TO_DNG_WIN] \$dng_hash = $dng_hash\n" if(defined($opts{t}));
  $ret_val = true;

#  print OUTPUT Dumper(%{$raw_ref});

  # if there are more then 1 directory with raw files
  foreach ( keys %{$dng_hash} )
  {
    # replace last 3 characters with dng extension
    $raw_dir = $_;
    $dng_dir = $_;
    $dng_dir =~ s/\w{3}$/$dng_ext/;
    mkdir $dng_dir, 0755 or die $! unless -d $dng_dir;
    printf STDOUT "[CONVERT_TO_DNG] created directory: $dng_dir\n";

    %work = map { $_ => 1 } 1 .. ($#{$$dng_hash{$_}} + 1);
    @work = sort {$a <=> $b} keys %work;

    # loop over number of raw files
    while (@work)
    {
      my $work = shift @work;

      print STDOUT "[CONVERT_TO_DNG] \$work = $work\n" if(defined($opts{t}));
      print STDOUT "[CONVERT_TO_DNG] \@work = @work\n" if(defined($opts{t}));

      print STDOUT "[CONVERT_TO_DNG] $$ kid executing $work\n" if(defined($opts{t}));
      if(defined(${$$dng_hash{$_}}[$work-1]) && (${$$dng_hash{$_}}[$work-1] ne ""))
      {
        $ret_val = convert_to_dng_task( $dng_dir, "$raw_dir/${$$dng_hash{$_}}[$work-1]" );
      }
      print STDOUT "[CONVERT_TO_DNG] $$ kid done $work\n" if(defined($opts{t}));
    }
  }
  print STDOUT "<- [CONVERT_TO_DNG]\n" if(defined($opts{t}));
  return $ret_val;
}


__END__
