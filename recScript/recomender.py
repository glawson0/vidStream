#! /usr/bin/python
import pymongo

connection=pymongo.Connection()

db=connection['prod']

streams=db.streams.find({"rec":True, "cur":False})

for stream in streams:
   news= db.streams.find_and_modify({"_id": stream["_id"],"rec": True, "cur":False},
      {"$set":{"cur":True}})
   if news == None:
      continue
   videos=db.videos.find({"$and" : [{"k" :{"$in" : news['bw'].keys()}},{'_id' :{"$nin" : news['d'].keys()}}, { '_id':{"$nin" : news['w']}}, { '_id' :{"$nin" : news['v']}}]}) 
   print videos.count()
   sd=news['du']['sd']
   if sd<3:
      nsd =news['du']['m']*0.2
      if nsd < 20:
         nsd=20
      if nsd >sd:
         sd=nsd
   maxt=news['du']['m']+sd
   mint=news['du']['m']-sd
   scores =[]
   for video in videos:
      count=0
      if(video['du']<mint or video['du']>maxt):
         count -=10
      for word in video['k']:
         if word in news['bw']:
            count+=news['bw'][word]
         elif word in news['mw']:
            count-=1
      if video['c'] in news['cs']:
         count+=5
      scores.append((count,video))

   scores.sort(key=lambda tup: -tup[0])
   print scores[0][0]
   db.streams.update({'_id': news['_id']},{'$pushAll': {'w': [ x[1]['_id'] for x in  (scores[0:6])] }})
   db.streams.update({'_id': news['_id']},{'$set':{"rec":False, "cur":False}})

   
