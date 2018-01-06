# coding: utf-8

from django.core.wsgi import get_wsgi_application
import leancloud
import md5
import time
import sys


reload(sys)
sys.setdefaultencoding("utf-8")
engine = leancloud.Engine(get_wsgi_application())

@engine.define
def create_group(**params):
    print "Create group: {}".format(params["creatorId"])
    
    # create a conversation
    conversation = leancloud.Conversation()
    conversation.set("name", params["topic"])
    conversation.set("creatorId", params["creatorId"])
    conversation.set("creatorName", params["creatorName"])
    conversation.set("members", [params["creatorId"]])
    conversation.save()
    
    # create invitations
    Invitation = leancloud.Object.extend("Invitation")
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

@engine.define
def join_group(**params):
    print "Join group: {} -> {}".format(params["userId"], params["groupId"])
    
    # add to members list
    query_conv = leancloud.Query(leancloud.Conversation)
    conversation = query_conv.get(params["groupId"])
    members = conversation.get("members")
    members.append(params["userId"])
    conversation.set("members", members)
    conversation.save()
    
    # delete invitations
    Invitation = leancloud.Object.extend("Invitation")
    query_inv = leancloud.Query(Invitation)
    query_inv.equal_to("invitedId", params["userId"])
    invitations = query_inv.find()
    leancloud.Object.destroy_all(invitations)

@engine.define
def quit_group(**params):
    print "Quit group: {} -> {}".format(params["userId"], params["groupId"])
    
    # remove from members list
    query = leancloud.Query(leancloud.Conversation)
    conversation = query.get(params["groupId"])
    members = conversation.get("members")
    members.remove(params["userId"])
    conversation.set("members", members)
    conversation.save()
