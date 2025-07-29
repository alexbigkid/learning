"""ABK Google Cloud Python Pulumi website"""

import os
import mimetypes
import pulumi
from pulumi_gcp import storage

# ------------------------------------------
# local variables
# ------------------------------------------
abk_main_page = "index.html"
abk_error_page = "404.html"
main_website_folder = "abk-websites"


# ------------------------------------------
# local functions
# ------------------------------------------
def get_subfolders(folder_path: str) -> list[str]:
    """Gets a list of subfolders in the given folder path.
    Args:
        folder_path (str): The path to the folder.
    Returns:
        list[str]: A list of subfolder names.
    """
    return [f.name for f in os.scandir(folder_path) if f.is_dir()]


def get_mime_type(file_path: str) -> str:
    """Gets the MIME type of a file based on its extension.
    Args:
        file_path (str): The path to the file.
    Returns:
        str: The MIME type of the file. Defaults to "application/octet-stream" if unknown.
    """
    mime_type, _ = mimetypes.guess_type(file_path)
    return mime_type if mime_type else "application/octet-stream"


def upload_directory(directory: str, bucket_name: str, subfolder_name: str):
    """Upload directory to GCS bucket while preserving the folder structure.
    Args:
        directory (str): The directory to upload.
        bucket_name (str): bucket name to upload to.
        subfolder_mame (str): The name of the subfolder in the bucket to upload to.
    Returns:
        assets (list): A list of BucketObject instances representing the uploaded files.
    """
    assets = []
    for root, _, files in os.walk(directory):
        for file in files:
            file_path = os.path.join(root, file)
            relative_path = os.path.relpath(file_path, directory) # keep the folder structure
            # gcs_path = f"{subfolder_name}/{relative_path}" # include subfolder name in GCS
            gcs_path = relative_path.replace("\\", "/")  # replace backslashes with forward slashes for GCS path

            resource_name = f"{subfolder_name}-{gcs_path}".replace("/", "-")

            mime_type = get_mime_type(file_path)
            asset = storage.BucketObject(
                resource_name,
                bucket=bucket_name,
                name=gcs_path,
                source=pulumi.FileAsset(file_path),
                content_type=mime_type
            )
            assets.append(asset)

            # pulumi.log.info(f"Uploaded {file_path} to gs://{bucket_name}/{gcs_path} with MIME type {mime_type}")
    return assets


# ------------------------------------------
# main
# ------------------------------------------
# get all subfolders
subfolders = get_subfolders(main_website_folder)

for subfolder in subfolders:
    subfolder_bucket_name = f"abk-gcp-website-{subfolder}"

    # Create a GCS bucket for website hosting
    subfolder_bucket = storage.Bucket(
        subfolder_bucket_name,
        location="US",
        website=storage.BucketWebsiteArgs(
            main_page_suffix=abk_main_page,
            not_found_page=abk_error_page,
        ),
        name=subfolder_bucket_name,
        uniform_bucket_level_access=True
    )

    # Make the bucket publicly accessible
    bucket_iam = storage.BucketIAMBinding(
        f"public-access-{subfolder}",
        bucket=subfolder_bucket.id,
        role="roles/storage.objectViewer",
        members=["allUsers"]
    )

    # Upload all files in the folder
    subfolder_path = os.path.join(main_website_folder, subfolder)
    uploaded_files = upload_directory(subfolder_path, subfolder_bucket.name, subfolder)

    # Output the website URL
    pulumi.export(f"{subfolder}-website_url", pulumi.Output.concat("http://", subfolder_bucket.id, ".storage.googleapis.com/", abk_main_page))
    # pulumi.export(f"{subfolder}-website_url", pulumi.Output.concat("http://", subfolder_bucket.name, ".storage.googleapis.com/", abk_main_page))
    pulumi.log.info(f"Website for {subfolder} is available at: http://{subfolder_bucket.id}.storage.googleapis.com/{abk_main_page}")
    # pulumi.log.info(f"Website for {subfolder} is available at: http://{subfolder_bucket.name}.storage.googleapis.com/{abk_main_page}")
