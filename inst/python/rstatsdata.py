# Code to tweet rstats datasets
# To setup on AWS Lambda:
#
# ```
# mkdir rstatsdata
# pip install pandas -t ~/rstatsdata
# pip install python-twitter -t ~/rstatsdata
# # move data-packages csv to rstatsdata folder
# # zip all files 
# # open lambda console
# # create new function
# # # blank function
# # # configure trigger - cloudwatch events
# # # runtime - python3.6
# # # code entry -> upload zip
# # # handler -> rstatsdata.rdatatoots
# ```

import twitter
import pandas as pd


def rdatatoots(event, context):
	api = twitter.Api(consumer_key='',
		consumer_secret='',
		access_token_key='',
		access_token_secret='')

	data = pd.read_csv('pkgs_datasets_name-title.csv')
	data_sub = data.sample(1)

	pre_fix = "#rdata #rstats: "
	cran_link = "https://cran.r-project.org/package=" + data_sub.iloc[0,0]
	toot	= pre_fix + data_sub.iloc[0,1] + " - " + cran_link

	status = api.PostUpdate(toot)
