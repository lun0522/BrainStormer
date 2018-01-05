# coding: utf-8

from django.core.wsgi import get_wsgi_application
import leancloud
import md5
import time
import sys


reload(sys)
sys.setdefaultencoding('utf-8')
engine = leancloud.Engine(get_wsgi_application())

@engine.define
def create_group(**params):
    # create a conversation
    conversation = leancloud.Conversation()
    conversation.set("name", params["topic"])
    conversation.set("creatorId", params["creatorId"])
    conversation.set("creatorName", params["creatorName"])
    conversation.set("members", [params["creatorId"]])
    conversation.save()
    
    # create invitations
    Invitation = leancloud.Object.extend('Invitation')
    for uid in params["invitedId"]:
        query = leancloud.Query(leancloud.User)
        if query.get(uid):
            invitation = Invitation()
            invitation.set("invitedId", uid)
            invitation.set("groupId", conversation.id)
            invitation.set("topic", params["topic"])
            invitation.set("inviterName", params["creatorName"])
            invitation.save()
    
    # return QR code string
    millisec = int(round(time.time() * 1000))
    qr_string = params["timestamp"] + params["topic"] + str(millisec)
    encryptor = md5.new()
    encryptor.update(qr_string) 
    return {"groupId": conversation.id, "encrypted": encryptor.hexdigest()}
