### To run the command type the following in the terminal 

###    $python downloadimage.py <path of the folder where html files are kept>

#### input : folder in which html files are 
#### output : downloads all the images in respective folders of the same name as html files name e.g. all the images in xyz.html would be downloaded in ./html_file_images/xyz folder


import argparse
import base64
import httplib2
import os 
import urllib2
import urllib
import codecs
import BeautifulSoup
from io import BytesIO 
import codecs
import csv
from PIL import Image
import requests


### folder where you want to keep all the html folders
download_folder = '/home/fatigue_internship/data/images/BH/'

def main_download(file):
    global download_folder
    htmlSource = open(str(file).encode('utf-8'), 'r')
    split_path = str(file).split('/')
    dirname = split_path[len(split_path) - 1].split('.')[0]
    os.makedirs(download_folder + dirname)
    bs = BeautifulSoup.BeautifulSoup(htmlSource)
    for images in bs.findAll('img'):
        img_url = images.get('src')
        img_path_split = str(img_url).split('/')
        img_name = img_path_split[len(img_path_split) - 1].strip(" \t\r")
	file_name, extension = os.path.splitext(img_name)
	
	if extension != ".jpg":
		continue

        img_new_path = download_folder + dirname + '/' +  img_name
        urllib.urlretrieve(str(img_url),img_new_path)

def call_main_download_img(input_dir):
    allfileslist = []
    for fname in os.listdir(input_dir):
        path =  os.path.join(input_dir,fname)
        if os.path.isdir(path):
            continue 
        else:
            allfileslist.append(path)
    for filename in allfileslist:
        split_name = filename.split('.')
        if split_name[len(split_name) - 1] == 'html':
            main_download(filename)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('html_files', help='the folder where you are keeping html files')
    args = parser.parse_args()
    call_main_download_img(args.html_files) 
