**Ping**
```
{"command": "ping","message-id":123}
> {"command":"ping","message":"pong","message-id":123,"result":"success"}

```

**Register**
```
{"command":"register","name":"teifion","password":"password1","email":"teifion@teifion"}
> {"command":"register","message":"User 'teifion' created, you can now login with this user","result":"success"}

```

**Login**
```
# Failure
{"command":"login","name":"teifion","password":"badpass"}
> {"command":"login","reason":"bad password","result":"failure"}

# Success
{"command":"login","name":"teifion","password":"password1"}
> {"command":"login","message":"You are now logged in as 'teifion'","result":"success"}
```

**Whoami**
```
{"command":"whoami"}
> {"command":"whoami","result":"success","user":{"id":1,"name":"teifion"}}
```

**Whois**
```
# Failure
{"command":"whois","id":0}
> {"command":"whois","message":"No user found by the id '0'","result":"failure"}

# Success
{"command":"whois","id":1}
> {"command":"whois","result":"success","user":{"id":1,"name":"teifion"}}

{"command":"whois","name":"teifion"}
> {"command":"whois","result":"success","user":{"id":1,"name":"teifion"}}
```

**Clients**
```
{"command":"clients"}
{"command":"clients","global_client_ids":[1],"local_client_ids":[1],"result":"success"}
```

**Message**
```
# Sending
{"command":"message","to":"teifion","content":"Hello!"}
> {"command":"message","result":"success"}

# Receipt
> {"command":"messaged","from":"someuser","content":"Hello!"}
```
