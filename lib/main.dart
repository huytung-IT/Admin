import 'dart:io';
import 'package:flutter/material.dart';
import 'api_Services.dart';
import 'Login.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home:Login(),
    );
  }
}

class AdminUserScreen extends StatefulWidget {
  @override
  _AdminUserScreenState createState() => _AdminUserScreenState();
}

class _AdminUserScreenState extends State<AdminUserScreen> {
  Map<String, String?> userAvatarPaths = {};
  List<User> users  = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _newUsernameController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _newRetypePasswordController = TextEditingController();
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _newPhoneController = TextEditingController();
  String? _newAvatarPath;
  File imageFile = File('path_to_your_image.jpg');

  @override
  void initState(){
    super.initState();
    getUsersFromApi();

}
  Future<void> getUsersFromApi() async {
    try {
      var responseData = await Services.getUsers();
      // for(var fetchedUsers in responseData ){
      //   print('${fetchedUsers.username}, ${fetchedUsers.id}');
      // }

      if (responseData != null) {
        List<User> fetchedUsers = responseData.map<User>((userData) {
          return User(
            username: userData.getUsername(),
            password: userData.getPassword(),
            email: userData.getEmail(),
            phoneNumber: userData.getPhoneNumber(),
            avatarUrl: userData.getAvatarUrl(),
            activated: userData.getActivated(),
            id: userData.getId(),
            createdAt: userData.getCreatedAt(),
            updatedAt: userData.getUpdatedAt(),
          );
        }).toList();

        setState(() {
          users = fetchedUsers;
        });
      } else {
        print('Lỗi khi tải dữ liệu người dùng: responseData là null hoặc không phải là List');
      }
    } catch (e) {
      print('Lỗi khi tải dữ liệu người dùng: $e');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Admin User'),
          actions: [
      const Padding(padding: EdgeInsets.only(top: 20)),
    IconButton(
    icon: const Icon(Icons.exit_to_app),
    onPressed: () async {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    }
      ),
      ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            DataTable(
              columnSpacing: 8,
              columns: const [
                DataColumn(label: Text('Username')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Phone Number')),
                DataColumn(label: Text('Avatar')),
                DataColumn(label: Text('Actions')),
              ],
              rows: users.map((user) {
                return DataRow(
                  cells: [
                    DataCell(Text(user.username)),
                    DataCell(Text(user.email)),
                    DataCell(Text(user.phoneNumber)),
                    DataCell(
                      Row(
                        children: [
                          userAvatarPaths.containsKey(user.username)
                              ? Image.file(
                            File(userAvatarPaths[user.username]!),
                            width: 20,
                            height: 20,
                          )
                              : CircleAvatar(
                            backgroundImage: NetworkImage(user.avatarUrl),
                            // radius: 10,
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image,);
                              if (result != null) {
                                setState(() {
                                  userAvatarPaths[user.username] = result.files.single.path!;
                                });
                              }
                              await Services.changeAvatarUrl(user.username, _newAvatarPath??'');
                              Services.uploadImage(imageFile, user.username);
                            },
                            style:ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.black12),
                             ),
                            // style: ElevatedButton.styleFrom(
                            //   padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                            // ),
                            child: const Text('Choose',
                              style: TextStyle(fontSize:12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      PopupMenuButton<String>(
                        onSelected: (String choice) async {
                          if (choice == 'delete') {
                            await Services.deleteUser(user.username);
                            await getUsersFromApi();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Xóa thành công!'),
                              ),
                            );
                          }
                          if (choice == 'changePassword') {
                            _showChangePasswordDialog(user.username);
                          }
                          if (choice == 'changeEmail') {
                            _showChangeEmailDialog(user.username);
                          }
                          if (choice == 'changePhone') {
                            _showChangePhoneDialog(user.username);
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            const PopupMenuItem<String>(
                              value: 'changePhone',
                              child: ListTile(
                                leading: Icon(Icons.phone),
                                title: Text('Change Phone'),
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'changeEmail',
                              child: ListTile(
                                leading: Icon(Icons.email),
                                title: Text('Change Email'),
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'changePassword',
                              child: ListTile(
                                leading: Icon(Icons.lock),
                                title: Text('Change Password'),
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: ListTile(
                                leading: Icon(Icons.delete),
                                title: Text('Delete'),
                              ),
                            ),
                          ];
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: (){
                  _showAddUserDialog(context);
                },
                child: const Text('Thêm tài khoản')
            ),
          ],
        ),
      ),
    );
  }
  //Đổi mật khẩu
  Future<void> _showChangePasswordDialog(String username) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
                children: [
            Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue),
            ),
            child:  TextField(
              controller: _newPasswordController,
              decoration: InputDecoration(labelText: 'New Password'),
            ),
          ),
          SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue),
                    ),
                    child:  TextField(
                      controller: _newRetypePasswordController,
                      decoration: InputDecoration(labelText: 'Retype New Password'),
                    ),
                  ),
                ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: ()async {
                Services.changePassword(username, _newPasswordController.text, _newRetypePasswordController.text);
                await getUsersFromApi();
                Navigator.pop(context);
                _newPasswordController.clear();
                _newRetypePasswordController.clear();

              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Đổi email
  Future<void> _showChangeEmailDialog(String username) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Email'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue),
                  ),
                  child:  TextField(
                    controller: _newEmailController,
                    decoration: InputDecoration(labelText: 'New Email'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: ()async {
                Services.changeEmail(username, _newEmailController.text);
                await getUsersFromApi();
                Navigator.pop(context);
                _newEmailController.clear();

              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Đổi sđt
  Future<void> _showChangePhoneDialog(String username) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Phone'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue),
                  ),
                  child:  TextField(
                    controller: _newPhoneController,
                    decoration: InputDecoration(labelText: 'New Phone'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async{
                Services.changePhone(username, _newPhoneController.text);
                await getUsersFromApi();
                Navigator.pop(context);
                _newPhoneController.clear();

              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Thêm người dùng mới
  Future<void> _showAddUserDialog(BuildContext context) async{
    return showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text('Thêm tài khoản'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue),
                    ),
                    child:  TextField(
                      controller: _newUsernameController,
                      decoration: InputDecoration(labelText: 'Username'),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue),
                    ),
                    child:  TextField(
                      controller: _newPasswordController,
                      decoration: InputDecoration(labelText: 'Password'),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue),
                    ),
                    child:  TextField(
                      controller: _newRetypePasswordController,
                      decoration: InputDecoration(labelText: 'RetypePassword'),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue),
                    ),
                    child:   TextField(
                      controller: _newEmailController,
                      decoration: InputDecoration(labelText: 'Email'),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue),
                    ),
                    child:  TextField(
                      controller: _newPhoneController,
                      decoration: InputDecoration(labelText: 'Phone Number'),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                      onPressed:() async{
                        FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
                        if(result != null){
                          setState(() {
                           File imageFile = File('path_to_your_image.jpg');
                            String? username;
                            _newAvatarPath = result.files.single.path;
                            Services.uploadImage(imageFile, username??'');
                          });
                        }
                      },
                      child: Text('Choose Image'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed:(){
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
              ),
              ElevatedButton(
                  onPressed: () async{
                    try {
                      Map<String, dynamic> response = await Services.AddUser(
                          _newUsernameController.text,
                          _newPasswordController.text,
                          _newRetypePasswordController.text,
                          _newEmailController.text,
                          _newPhoneController.text,
                          _newAvatarPath??'',
                      );
                      if(response != null){
                        print('addUser successfully');
                      }else{
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Add User Failed'),
                              content: const Text('Failed to add user. Please try again.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }catch(error) {
                      print('Error:$error');
                    }
                    await getUsersFromApi();
                    Navigator.of(context).pop();
                    _newUsernameController.clear();
                    _newPasswordController.clear();
                    _newRetypePasswordController.clear();
                    _newEmailController.clear();
                    _newPhoneController.clear();
              },
                  child: Text('Save'),
              ),
            ],
          );
        }
    );
  }
}
class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }

}
