import numpy as np
import caffe
import PIL
import os
from PIL import Image

def score(imgPath, model_def_a, model_weights_a):

	#attributes & aesthetics
	mean10K = [111.452247751, 108.607499157, 100.449740826]#mean for attributes
	mean_value40K = [109.692900367, 104.676436555, 97.6725598888]#mean for aesthetics

	attributeNet = caffe.Net(model_def_a, model_weights_a, caffe.TEST)

	#10 attributes
	attributesName = ['BalacingElements', 'ColorHarmony', 'Content',
	'DoF', 'Light', 'Object', 'Repetition', 'RuleOfThirds', 'Symmetry', 'VividColor']

	#------------------get aesthetic Feature----------------------------------------------------
	tmpImg = Image.open(imgPath).resize((224, 224), PIL.Image.ANTIALIAS)
	tmpImg = np.array(tmpImg).astype('float32')
	tmpImgA = tmpImg - np.array(mean_value40K)
	tmpImgA = tmpImgA[:, :, ::-1].astype('float32') #BGR
	images = np.transpose(tmpImgA, (2, 0, 1))

	attributeNet.blobs['data'].data[0] = np.array(images).astype(np.float32)
	#---------------------get attributes Feature--------------------------------------------
	img = tmpImg - np.array(mean10K)
	img = img[:, :, ::-1].astype('float32') #BGR
	images = np.transpose(img, (2, 0, 1))

	attributeNet.blobs['data_p'].data[0] = np.array(images).astype(np.float32)

	#---------------------run--------------------------------------------
	output = attributeNet.forward()

	scoreAll = dict()
	scoreAll['Aesthetics'] = output['loss3_new/classifier'][0][0]

	for name in attributesName:
		scoreAll[name] = output['loss3_new/classifier_' + name][0][0]
	return scoreAll

caffe.set_mode_gpu()
caffe.set_device(0)

if __name__ == '__main__':
	path_to_campaign_folders = '/home/ubuntu/skedia/image_aesthetics/image_files/BH/'

	campaign_list = os.listdir(path_to_campaign_folders)

	path_to_output_file = '/home/ubuntu/skedia/image_aesthetics/output/aesthetics.csv'

	f_out = open(path_to_output_file, "a+")

	for campaign in campaign_list:
		path_to_campaign = path_to_campaign_folders + campaign

		image_file_list = os.listdir(path_to_campaign)

		for image in image_file_list:
			file_name, extension = os.path.splitext(image)

			if extension != ".jpg":
				continue
			path_to_image_file = path_to_campaign + "/" + image
			brand_name = campaign.split("-")[0].strip(" \t\r")
			campaign_code = campaign.split("-")[1].strip(" \t\r")

			#image path
			imgPath = path_to_image_file
			#prototxt
			model_def = '/home/ubuntu/skedia/image_aesthetics/attNaes.prototxt'
			#model
			model_weights = '/home/ubuntu/skedia/image_aesthetics/attNaesSmall.caffemodel'

			#get the aesthetics score and 10 attributes, return a dictionary
			scoreAll = score(imgPath, model_def, model_weights)

			output_string = brand_name + ", " + campaign_code + ", " + image

			print '---------------score----------------'
			for key in scoreAll:
				print key, scoreAll[key]
				output_string = output_string + ", " + str(scoreAll[key])

			f_out.write(output_string+"\n")


	f_out.close()
