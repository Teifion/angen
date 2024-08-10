# Users
As with matches, the database expects user profiles to link match events against. This allows you to determine if specific groups of players exhibit differently; e.g. better players may be less likely to make use of an interface aid.

These user accounts are not expected to be used so the process for creating them is very light on details.

### Create user
[Example bru](/bru/Matches/Create_user.bru)
- Method: `POST`
- URL: `api/account/create_user`

The body of the message should be a JSON object with the following:

Required:
- name: String

Optional
- id: The UUID of the user, if not included a random one will be generated
  
Example request
```json
{
  "id": "4dd6e24d-08a5-4a05-88dd-6bbfffd8c325",
  "name": "My first user"
}
```

Example success
```json
{
  "id": "4dd6e24d-08a5-4a05-88dd-6bbfffd8c325",
  "name": "My first user",
  "result": "User created"
}
```
