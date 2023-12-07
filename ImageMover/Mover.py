from PIL import Image
from PIL.ExifTags import TAGS
from datetime import datetime
import shutil
from pathlib import Path

###############################################################################
# AI generated script to move images based on EXIF date to subfolders         #
#                                                                             #
# Version 0.1-20231211                                                        #
# * Initial version                                                           #
#                                                                             #
###############################################################################

def get_image_date(image_path):
    try:
        with Image.open(image_path) as img:
            exif_data = img._getexif()
            if exif_data is not None:
                for tag, value in exif_data.items():
                    tag_name = TAGS.get(tag, tag)
                    if tag_name == 'DateTimeOriginal':
                        return datetime.strptime(value, "%Y:%m:%d %H:%M:%S").strftime("%Y%m%d")
    except Exception as e:
        print(f"Error reading EXIF data for {image_path}: {e}")
    return None


def organize_images(source_dir, destination_dir):
    source_path = Path(source_dir)
    destination_path = Path(destination_dir)

    if not destination_path.exists():
        destination_path.mkdir(parents=True)

    no_date_dir = destination_path / 'NoDate'
    if not no_date_dir.exists():
        no_date_dir.mkdir()

    for image_path in source_path.glob('*.*'):
        if image_path.suffix.lower() in ('.jpg', '.jpeg', '.png', '.gif'):
            date = get_image_date(image_path)

            if date is not None:
                destination_subdir = destination_path / date
                if not destination_subdir.exists():
                    destination_subdir.mkdir()

                destination_file = destination_subdir / image_path.name
                counter = 1
                while destination_file.exists():
                    base, ext = image_path.stem, image_path.suffix
                    image_path = Path(f"{base}_{counter}{ext}")
                    destination_file = destination_subdir / image_path.name
                    counter += 1

                shutil.move(image_path, destination_file)
            else:
                shutil.move(image_path, no_date_dir / image_path.name)


if __name__ == "__main__":
    source_directory = "TODO"
    destination_directory = "TODO"

    organize_images(source_directory, destination_directory)
