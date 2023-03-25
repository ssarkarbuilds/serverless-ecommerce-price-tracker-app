from bs4 import BeautifulSoup 
from urllib.request import urlopen, Request
import json
import boto3


def lambda_handler(event, context):   
    if 'source' not in event:
        # if request originates from API Gateway, add new item to wishlist
        body = json.loads(event['body'])
        print ('body', body)
        
        url = body['id']['S']
        # price = check_price_amazon(url) # use this if you want to add the item with current price
        price = body['price']['N']
        name = body['name']['S']
        add_item_to_wishList(url, price, name)
    else:
        # if request originates from EventBrigde rule events, perform price check for all items in wishlist
        read_wishlist()
    
    return {
            'statusCode': 200,
            'headers': {
            "Access-Control-Allow-Origin": "*",
            },
            'body': 'Request processed successfully!'
        }    


def read_wishlist():
    dynamodb = boto3.client('dynamodb')
    response = dynamodb.scan(
        TableName='<your-table-name-here>'
    )
    data = response['Items']
    # print ('dynamodb data', data)
    
    for item in data:
        print ('checking item', item)
        #fetch current price and compare with historical price data
        curr_price = check_price_amazon(item['id']['S'])
        old_price = item['price']['N']
        
        # print ('price comparison', old_price, curr_price)
        if (int(curr_price) < int(old_price)):
            # send email update
            print ('Price Drop Alert!', item['name']['S'])
            send_mail(item['name']['S'], curr_price)
    
    
        
def check_price_amazon(url):
    headers = {
        "User-Agent": "", # to get your user agent google : my user agent 
        "Accept-Charset": "ISO-8859-1,utf-8;q=0.7,*;q=0.3",
        "Accept-Encoding": "none",
        "Accept-Language": "en-US,en;q=0.8",
        "Connection": "keep-alive",
        "Referer": "https://amazon.in/",
        "authority": "amazon.in",
        "method": "GET",
        "scheme": "https",
        "accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
        "cache-control": "max-age=0"
    }
    try:
        req = Request(url=url, headers=headers)
        sauce = urlopen(req).read()
        soup = BeautifulSoup(sauce, "html.parser")
        title = soup.find('title').get_text()
        price = soup.find('span',{'class':'a-price-whole'}).get_text()
        price = price.replace(",","").replace("₹", "").replace(".","")
        
        # print ('title', title, 'current price is', price)
        
    except Exception as e:
        print ('Error occurred with', e)
    
    return price

def send_mail(name, price):
    if price is not None:
        sns = boto3.client('sns')
        notification = "Your wish list item - " + str(name)+ " is now available @ ₹" + str(price) + "!"
        
        sns.publish (
            TargetArn = "<your-sns-topic-arn-here>",
            Message = json.dumps({'default': notification}),
            MessageStructure = 'json'
        )

def add_item_to_wishList(url, price, title):
    dynamodb = boto3.client('dynamodb')
    dynamodb.put_item(
    TableName='<your-table-name-here>',
    Item={
        'id': {
          'S': url
        },
        'price': {
          'N': price
        },
        'name': {
          'S': title
        }
    })
