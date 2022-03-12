"""
Useful helper commands to be used across all python programs
"""
import logging.config
import logging
import json
import os
import pickle

INFO = logging.INFO
DEBUG = logging.DEBUG
LOG_SEP = "="

################################################################################################################
# Logger Useful commands
################################################################################################################


def log_from_file_path(filepath: str) -> logging.Logger:
    """
    Create a logger that is created using the program path
    :param filepath: program path
    :param log_level: debug level
    :return: logger
    """
    filename = os.path.basename(filepath)
    fileshort = os.path.splitext(filename)[0]
    logger = log(fileshort)
    return logger


def log(name):
    """
    Create a logger that is based on a name
    :param name: Name to be used in the logger
    :return: the logger
    """
    resource_path = "resources/"
    log_conf_file = resource_path + "logging.info.ini"
    logging.config.fileConfig(log_conf_file, disable_existing_loggers=False)
    return logging.getLogger(name)


################################################################################################################
# File commands
################################################################################################################
def file_to_string(filename):
    """
    Read the file and return its content in a string
    :param filename: File to read
    :return: content of file
    """
    with open(filename, 'r') as file:
        data = file.read()
    return data


def file_to_list(file_name):
    """
    Read a file and place each line into an array of text
    :param file_name: file to read
    :return: Array output
    """
    with open(file_name) as ds_file:
        ds_list = [line.rstrip('\n') for line in ds_file]
    return ds_list


def file_to_json(file_name):
    """
    Read a file and convert it into json structure in memory
    :param file_name: file to read
    :return: json structure
    """
    with open(file_name, 'r') as file:
        data = file.read().replace('\n', '')
    return json.loads(data)


def read_pickle_file(pickel_file):
    """
    Read the given picket file and return it
    :param pickel_file: pickle file to read
    :return: the python object
    """
    pickle_object = {}
    if os.path.exists(pickel_file):
        with open(pickel_file, 'rb') as handle:
            pickle_object = pickle.load(handle)
    return pickle_object


def save_pickle_file(pickel_file, hash_dic):
    """
    Save a python object to a file
    :param pickel_file: pickle file to save to
    :param hash_dic: the object to save
    :return: n/a
    """
    with open(pickel_file, 'wb') as handle:
        pickle.dump(hash_dic, handle, protocol=pickle.HIGHEST_PROTOCOL)


def save_text_file(file_name, text):
    """
    Create a file with the context of the text
    :param file_name: file to create
    :param text: text to insert into the file
    :return: n/a
    """
    with open(file_name, 'w') as fwrite:
        fwrite.write(text)

################################################################################################################
# Generic Useful commands
################################################################################################################


def percentage(now, maximum):
    """
    Given the present (now) value and the maximum value
    determine the percentage (now/maximum * 100) we have got to and return as a string
    Since now tends to be from 0 to maximum-1, we take 1 off of maximum
    :param now: The present value through a list
    :param maximum: The number of items in the list
    :return: a string represnting percentage
    """
    percentage_value = (now / (maximum - 1)) * 100
    out = "{:6.2f}%".format(percentage_value)
    return out


def hex_short(value):
    """
    Give an integer in value, convert it to a hexidecial but remove the 0x
    :param value: the integer
    :return: the shorted version of hex
    """
    hex_value = hex(value)[2:]
    if len(hex_value) == 1: hex_value = f"0{hex_value}"
    return hex_value
