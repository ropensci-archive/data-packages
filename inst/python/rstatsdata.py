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
