"""
This module holds all the memory type functions
"""
import tkinter
import tkinter.filedialog
import os
import zipfile
import helper

LOG = helper.log_from_file_path(__file__)


def short_hex(value):
    """
    Convert to a nice hex number without the 0x in front to save screen space
    :param value: value
    :return: short string hex representation
    """
    hex1 = hex(value)
    hex2 = hex1[2:]
    if len(hex2) == 1: hex2 = "0" + hex2
    return hex2


def dump_column_dbs(filename, memory, mem_ptr, width):
    """
    Display to the console the assembler DB statements to make the images for a given width
    :param filename: file where the memory was recieved
    :param memory: spectrum memory
    :param mem_ptr: memory pointer
    :param width: character width
    :return: n/a
    """
    LOG.info(f"dump_column_dbs(filename:{filename}, len(memory):{len(memory)}, mem_ptr:{mem_ptr}, width:{width}")
    width8 = width * 8
    print("; " + "=" * 100)
    print(f"; {filename}   size:{width8}/{hex(width8)}   memory:{mem_ptr}/{hex(mem_ptr)} ")
    print("; " + "=" * 100)
    for i in range(mem_ptr, mem_ptr + 40 * width8, width8):
        dbs = "  db "
        for j in range(i, i + width8):
            hex1 = short_hex(memory[j])
            dbs += "$" + hex1 + ","
        dbs = dbs[:-1]
        print(dbs)


def dump_graphics_dbs(filename, memory, mem_ptr, width, height, images):
    """
    Display to the console the assembler DB statements to make the images for a given width
    :param filename: file where the memory was recieved
    :param memory: spectrum memory
    :param mem_ptr: memory pointer
    :param width: character width
    :param height: The number of characters high the image is
    :param images: The count of the number of images
    :return: n/a
    """
    LOG.info(f"dump_graphics_dbs(filename:{filename}, len(memory):{len(memory)}, mem_ptr:{mem_ptr}, width:{width}, height:{height}, images:{images}")
    if width == 0:
        print("Select image size by hitting the red sizes")
        return
    width8 = width * 8; height8 = height * 8
    print("; " + "=" * 100)
    print(f"; {filename}   size:{width8}:{hex(width8)} / {height8}:{hex(height8)}   memory:{mem_ptr}/{hex(mem_ptr)} ")
    print("; " + "=" * 100)

    for image in range(0, images):
        print(f"; image{image}   size:{width8}:{hex(width8)} / {height8}:{hex(height8)}   memory:{mem_ptr}/{hex(mem_ptr)} ")
        for i in range(mem_ptr, mem_ptr + height * width8, width8):
            dbs = "  db "
            for j in range(i, i + width8):
                hex1 = short_hex(memory[j])
                dbs += "$" + hex1 + ","
            dbs = dbs[:-1]
            print(dbs)
        mem_ptr += width8 * height


def prompt_file():
    """
    Throw up a dialog box to get a filename to process
    :return: filename
    """
    LOG.info("prompt_file")
    win = tkinter.Tk()
    win.withdraw()
    file_name = tkinter.filedialog.askopenfilename(parent=win)
    win.destroy()
    LOG.info(f"prompt_file: out: file_name:{file_name}")
    return file_name


def get_biggest_file_in_zip(zipfilename):
    """
    Pull the largerst file from a zip file as this is most likely the spectrum rom
    :param zipfilename:
    :return: spectrum memory
    """
    LOG.info(f"get_biggest_file_in_zip zipfilename:{zipfilename}")
    data = ""
    with zipfile.ZipFile(zipfilename, 'r') as zip_handle:
        for info in zip_handle.infolist():
            if info.file_size >= len(data):
                data = zip_handle.read(info.filename)
    LOG.info(f"get_biggest_file_in_zip out: len(data):{len(data)}")
    return data


def read_binary_file(local_filename):
    """
    This is by no means close to perfect as there are lots of different file formats which this doesn't
    take into consideration. To do this better we could have a read_file for each file type.
    For now though, we just care about finding graphics and they are often not compressed so we're good!
    :param local_filename: file to read
    :return: (actual file, memory)
    """
    LOG.info(f"read_binary_file(local_filename: {local_filename})")
    out_filename = local_filename
    if os.path.exists(local_filename):
        if local_filename[-4:] == ".zip":
            data = get_biggest_file_in_zip(local_filename)
        else:
            with open(local_filename, "rb") as binaryfile:
                bin_data = bytearray(binaryfile.read())
                data = bin_data[27:]
        if len(data) <= 49152: memory = bytearray(16384) + data + bytearray(49152 - len(data))
        else: memory = bytearray(16384) + data[:49152]
    else:
        out_filename = prompt_file()
        return read_binary_file(out_filename)
    LOG.info(f"read_binary_file out: out_filename:{out_filename}, len(memory):{len(memory)}")
    return (out_filename, memory)
