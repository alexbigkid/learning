""" Implementation of the get_hardware_id functionality on all syupported OS types and all supported hardware
    Supported OS: Ubuntu, Debian, Raspbian, MacOS, Windows
    Supported hardware: ARM64v7. ARM64, AMD64
"""
from abc import ABCMeta, abstractmethod
from enum import Enum
import json
import re
import sys
import platform
import subprocess
from typing import NamedTuple
# pip install distro
import distro
import logging

logging.basicConfig(level=logging.INFO)
hwid_logger = logging.getLogger(__name__)

def function_trace(original_function):
    """Decorator function to help to trace function call entry and exit
    Args:
        original_function (_type_): function above which the decorater is defined
    """
    def function_wrapper(*args, **kwargs):
        hwid_logger.debug("-> {}".format(original_function.__name__))
        result = original_function(*args, **kwargs)
        hwid_logger.debug("<- {}".format(original_function.__name__))
        return result
    return function_wrapper



class CpuMakeSnInfo(NamedTuple):
    """Contains info about CPU make and serial number"""
    cpu_make: str
    cpu_sn: str


class CpuArchInfo(NamedTuple):
    """Contains info about CPU architecture"""
    arch: str
    bits: str


class SUPPORTED_OS_TYPE(Enum):
    """Supported OS type"""
    LINUX_OS    = "Linux"
    MAC_OS      = "Darwin"
    WINDOWS_OS  = "Windows"


class SUPPORTED_LINUX_OS(Enum):
    """Supported Linux OS type"""
    DEBIAN    = "debian"
    RASPBIAN  = "raspbian"
    UBUNTU    = "ubuntu"


class SUPPORTED_HW_TYPE(Enum):
    """Supported hardware type"""
    ARM64V7     = "armv7l"
    AMD64V8     = "aarch64"
    ARM64       = "arm64"
    AMD64       = "x86_64"


class IOsType(metaclass=ABCMeta):
    """Interface for the OsType class"""
    prefix:str

    @classmethod
    def __subclasshook__(cls, subclass):
        return (
            hasattr(subclass, 'find_cpu_serial_number') and
            callable(subclass.find_cpu_serial_number) or
            NotImplemented
        )

    @abstractmethod
    def find_cpu_serial_number(self) -> CpuMakeSnInfo:
        raise NotImplementedError



class Device():
    """Device class"""
    os_type:IOsType
    hw_arch:CpuArchInfo

    def __init__(self, os_type:IOsType, hw_arch:CpuArchInfo):
        self.os_type = os_type
        self.hw_arch = hw_arch

    def get_hardware_id(self) -> str:
        """Gets hardware id"""
        cpu_info = self.os_type.find_cpu_serial_number()
        hardware_id = "_".join([self.os_type.prefix, self.hw_arch.arch, self.hw_arch.bits, cpu_info.cpu_make, cpu_info.cpu_sn])
        return hardware_id


# -----------------------------------------------------------------------------
# OS concreate implementation
# -----------------------------------------------------------------------------
class OSLinux(IOsType):
    """Linux common specific implementation"""

    @function_trace
    def _find_cpu_serial_number_from_proc_cpuinfo(self) -> CpuMakeSnInfo:
        """ Finds CPU number and model from /proc/cpuinfo file
            It does it safe way if one value is failed to be read
            there is still posibility that the other values could be read successfully
        """
        cpu_make = cpu_sn = ""
        with open('/proc/cpuinfo', mode="r", encoding="utf-8") as cpu_info_fh:
            try:
                output = cpu_info_fh.read()
            except Exception as read_exc:
                hwid_logger.error("_find_cpu_serial_number_from_proc_cpuinfo: read exception: {}".format(read_exc))
            else:
                try:
                    cpu_make = next(filter(lambda x: 'Hardware' in x, output.split('\n'))).split(':')[-1].replace(' ', '')
                except Exception as cpu_make_exc:
                    hwid_logger.error("_find_cpu_serial_number_from_proc_cpuinfo: cpu_make read exception: {}".format(cpu_make_exc))
                try:
                    cpu_sn = next(filter(lambda x: 'Serial' in x, output.split('\n'))).split(':')[-1].strip()
                except Exception as sn_exc:
                    hwid_logger.error("_find_cpu_serial_number_from_proc_cpuinfo: serial number read exception: {}".format(sn_exc))
        hwid_logger.debug("ABK: from proc cpu_make = {}".format(cpu_make))
        hwid_logger.debug("ABK: from proc serial_number = {}".format(cpu_sn))
        return CpuMakeSnInfo(cpu_make, cpu_sn)


    @function_trace
    def _find_cpu_serial_number_from_lshw_cmd(self) -> CpuMakeSnInfo:
        """ Finds CPU number and model from lshw command
            It does it safe way if one value is failed to be read
            there is still posibility that the other values could be read successfully
        """
        cpu_make = cpu_sn = ""
        try:
            output = subprocess.check_output(['lshw', '-json'], universal_newlines=True)
            output_json = json.loads(output)
        except Exception as exc:
            hwid_logger.error("_find_cpu_serial_number_from_lshw_cmd: exception: {}".format(exc))
        else:
            try:
                cpu_make = output_json.get('product', '').replace(' ', '')
            except Exception as cpu_make_exc:
                hwid_logger.error("_find_cpu_serial_number_from_lshw_cmd: cpu_make read exception: {}".format(cpu_make_exc))
            try:
                cpu_sn = output_json.get('serial', '').strip()
            except Exception as sn_exc:
                hwid_logger.error("_find_cpu_serial_number_from_lshw_cmd: serial number read exception: {}".format(sn_exc))
        hwid_logger.debug("ABK: from lshw cpu_make = {}".format(cpu_make))
        hwid_logger.debug("ABK: from lshw serial_number = {}".format(cpu_sn))
        return CpuMakeSnInfo(cpu_make, cpu_sn)


    @function_trace
    def _find_cpu_serial_number_from_sys_dir(self) -> CpuMakeSnInfo:
        """ Finds CPU number and model from /sys/firmware/devicetree/base directory
            It does it safe way if one value is failed to be read
            there is still posibility that the other values could be read successfully
            This function is for debian linux distro.
            It looks like the files contain some control characters, which we have to strip.
        """
        cpu_make = cpu_sn = ""
        CPU_SN_FILE = '/sys/firmware/devicetree/base/serial-number'
        CPU_NAME_FILE = '/sys/firmware/devicetree/base/name'
        CPU_MODEL_FILE = '/sys/firmware/devicetree/base/model'

        with open(CPU_SN_FILE, mode="r", encoding="utf-8") as cpu_sn_fh:
            try:
                cpu_sn = re.sub(r'\W+', '', cpu_sn_fh.read().strip())
            except Exception as read_exc:
                hwid_logger.error("_find_cpu_serial_number_from_sys_dir:{} read exception: {}".format(CPU_SN_FILE, read_exc))
        with open(CPU_NAME_FILE, mode="r", encoding="utf-8") as cpu_name_fh:
            try:
                cpu_make = re.sub(r'\W+', '', cpu_name_fh.read().strip())
            except Exception as read_exc:
                hwid_logger.error("_find_cpu_serial_number_from_sys_dir:{} read exception: {}".format(CPU_NAME_FILE, read_exc))
        # if CPU name reading was not sucessfull, try to get model instead
        if not bool(cpu_make):
            hwid_logger.debug("ABK: did not find CPU name, checking CPU model")
            with open(CPU_MODEL_FILE, mode="r", encoding="utf-8") as cpu_model_fh:
                try:
                    cpu_make = re.sub(r'\W+', '', cpu_model_fh.read().strip())
                except Exception as read_exc:
                    hwid_logger.error("_find_cpu_serial_number_from_sys_dir:{} read exception: {}".format(CPU_MODEL_FILE, read_exc))
        hwid_logger.debug("ABK: from proc cpu_make = '{}'".format(cpu_make))
        hwid_logger.debug("ABK: from proc serial_number = '{}'".format(cpu_sn))
        return CpuMakeSnInfo(cpu_make, cpu_sn)


    @function_trace
    def find_cpu_serial_number(self) -> CpuMakeSnInfo:
        """finds out the cpu make and the serial number
        Returns:
            CpuMakeSnInfo: tuple of the cpu make and the serail number
        """
        cpu_info = []
        cpu_info.append(self._find_cpu_serial_number_from_proc_cpuinfo())
        if all(s != '' for s in cpu_info[-1]):
            return cpu_info[-1]
        cpu_info.append(self._find_cpu_serial_number_from_lshw_cmd())
        if all(s != '' for s in cpu_info[-1]):
            return cpu_info[-1]
        cpu_info.append(self._find_cpu_serial_number_from_sys_dir())
        if all(s != '' for s in cpu_info[-1]):
            return cpu_info[-1]

        cpu_make = cpu_sn = ''
        for tuple_item in cpu_info:
            if tuple_item.cpu_make != '' and cpu_make == '':
                cpu_make = tuple_item.cpu_make
            if tuple_item.cpu_sn != '' and cpu_sn == '':
                cpu_sn = tuple_item.cpu_sn
        if cpu_make != '' and cpu_sn != '':
            return CpuMakeSnInfo(cpu_make, cpu_sn)

        raise Exception("Not able to get CPU Serial number")



class OSLinuxDebian(OSLinux):
    """Linux Debian specific implementation"""
    prefix = "".join([SUPPORTED_OS_TYPE.LINUX_OS.value, SUPPORTED_LINUX_OS.DEBIAN.value.capitalize()])



class OSLinuxRaspbian(OSLinux):
    """Linux Raspian specific implementation"""
    prefix = "".join([SUPPORTED_OS_TYPE.LINUX_OS.value, SUPPORTED_LINUX_OS.RASPBIAN.value.capitalize()])



class OSLinuxUbuntu(OSLinux):
    """Linux Ubuntu specific implementation"""
    prefix = "".join([SUPPORTED_OS_TYPE.LINUX_OS.value, SUPPORTED_LINUX_OS.UBUNTU.value.capitalize()])



class OSMacOS(IOsType):
    """MacOS specific implementation"""
    prefix = "MacOS"
    _CPU_MAKE_KEY_1 = 'Chip'
    _CPU_MAKE_KEY_2 = 'Processor Name'
    _CPU_SN_KEY     = 'Serial Number (system)'

    def _get_value_key(self, str_to_parse:str, key:str) -> str:
        return next(filter(lambda x: key in x, str_to_parse.split('\n'))).split(':')[-1].replace(' ', '')


    @function_trace
    def find_cpu_serial_number(self) -> CpuMakeSnInfo:
        cpu_make = serial_number = ""
        try:
            output = subprocess.check_output(['system_profiler', 'SPHardwareDataType'], universal_newlines=True)
        except Exception as exc:
            hwid_logger.error("OSMacOS.find_cpu_serial_number: read exception: {}".format(exc))
        else:
            try:
                cpu_make = self._get_value_key(output, self._CPU_MAKE_KEY_1)
            except Exception as cpu_make_exc:
                hwid_logger.error("OSMacOS.find_cpu_serial_number: cpu_make read exception: {}".format(cpu_make_exc))
                cpu_make = self._get_value_key(output, self._CPU_MAKE_KEY_2)
            serial_number = self._get_value_key(output, self._CPU_SN_KEY)
        hwid_logger.debug("ABK: from Mac system_profiler cpu_make = {}".format(cpu_make))
        hwid_logger.debug("ABK: from Mac system_profiler serial_number = {}".format(serial_number))
        return CpuMakeSnInfo(cpu_make, serial_number)



class OSWindowsOS(IOsType):
    """WindowsOS specific implementation"""
    prefix = "Windows"

    def find_cpu_serial_number(self) -> CpuMakeSnInfo:
        return CpuMakeSnInfo("", "")



# =============================================================================
# main functionality
# =============================================================================
@function_trace
def get_os_type() -> IOsType:
    """Gets OS type by try and error"""
    os_type_str = platform.system()
    # hwid_logger.debug("ABK: os_type_str = {}".format(os_type_str))
    if os_type_str == SUPPORTED_OS_TYPE.LINUX_OS.value:
        # dist_name, _, _ = platform.linux_distribution()
        dist_name = distro.id()
        dist_name_lower = dist_name.lower()
        if dist_name_lower == SUPPORTED_LINUX_OS.DEBIAN.value:
            return OSLinuxDebian()
        if dist_name_lower == SUPPORTED_LINUX_OS.UBUNTU.value:
            return OSLinuxUbuntu()
        if dist_name_lower == SUPPORTED_LINUX_OS.RASPBIAN.value:
            return OSLinuxRaspbian()
        raise Exception("Unsupported Linux distribution: {}".format(dist_name_lower))
    if os_type_str == SUPPORTED_OS_TYPE.MAC_OS.value:
        return OSMacOS()
    if os_type_str == SUPPORTED_OS_TYPE.WINDOWS_OS.value:
        return OSWindowsOS()
    raise Exception("Unsupported OS type: {}".format(os_type_str))


@function_trace
def get_device(os_type:IOsType) -> Device:
    """Gets hardware type by try and error"""
    machine_type = arch = ""
    try:
        machine_type = platform.machine()
        arch, _ = platform.architecture()
        hwid_logger.debug("ABK: machine_type = {}".format(machine_type))
        hwid_logger.debug("ABK: arch = {}".format(arch))
        if machine_type not in [item.value for item in SUPPORTED_HW_TYPE]:
            raise Exception("Unsupported hardware type: {}".format(machine_type))
    except Exception as exc:
        hwid_logger.error("Not able to get machine or arch exception: {}".format(exc))
    finally:
        return Device(os_type, CpuArchInfo(machine_type, arch))


def main():
    """Main function"""
    exit_code = 0
    try:
        os_type = get_os_type()
        device = get_device(os_type)
        hardware_id = device.get_hardware_id()
        hwid_logger.info("hardware_id = {}".format(hardware_id))
    except Exception as exc:
        hwid_logger.error("EXCEPTION: {}".format(exc))
        exit_code = 1
    finally:
        sys.exit(exit_code)


if __name__ == '__main__':
    main()
