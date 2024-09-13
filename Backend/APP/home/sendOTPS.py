from __future__ import print_function
import random 
import sib_api_v3_sdk
from sib_api_v3_sdk.rest import ApiException
from django.conf import settings
import requests
from twilio.rest import Client

def send_email(subject, email,message):
   
    configuration = sib_api_v3_sdk.Configuration()
    configuration.api_key['api-key'] = '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'

    api_instance = sib_api_v3_sdk.TransactionalEmailsApi(sib_api_v3_sdk.ApiClient(configuration))
    
    email_content = message
 
    sender = {
        "email": "shivanandgarg1234@gmail.com",
        "name": "SATCARD"
    }
    receiver = [
        {
            "email": email, 
        }
    ]

    try:
      
        api_response = api_instance.send_transac_email({
            "sender": sender,
            "to": receiver,
            "subject": "OTP",
            "textContent": email_content,
        })
        print("Email sent successfully:", api_response)
        # return Response({"message": "Email sent successfully"}, status=200)
    except ApiException as e:
        print("Exception when calling TransactionalEmailsApi->send_transac_email: %s\n" % e)
        # return Response({"error": "An error occurred while sending the email."}, status=500)


def sendSMS(phone, message):

    url = "https://www.fast2sms.com/dev/bulkV2"
    payload = {
        'authorization': 'cTQ8rnNFXspyLAlwBUGabJVY296PR1vCmZfEOI4egxhW7t3qHiMdz7P0L3yY9aOGwqV2bKspBiJ4F8oR',
        'message': message,
        'language': 'english',
        'route': 'q',
        'numbers': phone,
    }
    headers = {
        'cache-control': "no-cache"
    }
    response = requests.request("POST", url, data=payload, headers=headers)
    print(response.text)