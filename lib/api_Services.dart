import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart'as http;
class Services {
// Api dăng nhập
  static Future<dynamic> LoginUser(String username, String password) async {
    var url = Uri.parse('https://192.168.4.90:7074/api/auth/login');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer '
    };
    var requestBody = {
      "uid": username,
      "pwd": password,
    };
    var response = await http.post(
        url,
        headers: headers,
        body: json.encode(requestBody)
    );
    if (response.statusCode == 200) {
      var responseData = json.decode(utf8.decode(response.bodyBytes));
      return responseData;
    }
    else {
      print('Error from API: ${response.body}');
      throw Exception(
          'Failed to send question to API: ${response.reasonPhrase}');
    }
  }

// Api thêm người dùng.
  static Future<dynamic> AddUser(String username, String password, String retypePassword, String email, String phone, avatarUrl) async {
    var url = Uri.parse('http://118.70.117.208:5141/api/auth/admin/useraddnew');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer eyJhbGciOiJodHRwOi8vd3d3LnczLm9yZy8yMDAxLzA0L3htbGRzaWctbW9yZSNobWFjLXNoYTI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOiIxNzA4NDIxMTkwIiwidWlkIjoic3VwZXJhZG1pbiIsInVzZXJpZCI6IjY0NmRlMmVlZjk1OWIzYjhmN2JkM2IxMCIsImV4cCI6IjIxNDc0ODM2NDciLCJpc3MiOiJ2SllJWHZFVTUybWNTbE5SN01QbG9KMFowaU1QeFp4czF6Qk9oUjljWVVFPSIsImF1ZCI6InZKWUlYdkVVNTJtY1NsTlI3TVBsb0owWjBpTVB4WnhzMXpCT2hSOWNZVUU9IiwiYWNsIjp7fX0.O8UT-s647gR3cT0XYK6rpEAdMEKU1_tCz4G3W28umIw'
    };
    var requestBody = {
      "uid": username,
      "pwd": password,
      "pwdRetype": retypePassword,
      "email": email,
      "phone": phone,
      "avatarUrl": avatarUrl,
    };
    var response = await http.post(
        url,
        headers: headers,
        body: json.encode(requestBody)
    );
    if (response.statusCode == 200) {
      var responseData = json.decode(utf8.decode(response.bodyBytes));
      print('Response Data: $responseData');
      return responseData;
    } else if (response.statusCode == 400) {
      print('Bad Request: Invalid data');
      throw Exception('Bad Request: Invalid data');
    } else {
      print('Error from API: ${response.body}');
      throw Exception(
          'Failed to send question to API: ${response.reasonPhrase}');
    }
  }

// Api list danh sách người dùng
  static Future<List<User>> getUsers() async {
    var url = Uri.parse(
        'http://118.70.117.208:5141/api/auth/admin/listuser?skip=0&take=10&keyword=');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer eyJhbGciOiJodHRwOi8vd3d3LnczLm9yZy8yMDAxLzA0L3htbGRzaWctbW9yZSNobWFjLXNoYTI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOiIxNzA4NDIxMTkwIiwidWlkIjoic3VwZXJhZG1pbiIsInVzZXJpZCI6IjY0NmRlMmVlZjk1OWIzYjhmN2JkM2IxMCIsImV4cCI6IjIxNDc0ODM2NDciLCJpc3MiOiJ2SllJWHZFVTUybWNTbE5SN01QbG9KMFowaU1QeFp4czF6Qk9oUjljWVVFPSIsImF1ZCI6InZKWUlYdkVVNTJtY1NsTlI3TVBsb0owWjBpTVB4WnhzMXpCT2hSOWNZVUU9IiwiYWNsIjp7fX0.O8UT-s647gR3cT0XYK6rpEAdMEKU1_tCz4G3W28umIw'
    };
    var response = await http.get(
        url,
        headers: headers
    );
    if (response.statusCode == 200) {
      var responseData = json.decode(utf8.decode(response.bodyBytes))['rows'];
      List<User> users = [];
      for (var userData in responseData) {
        if (userData is Map<String, dynamic>) {
          var user = User.fromJson(userData);
          users.add(user);
        }
      }
      return users;
    } else {
      throw Exception('Failed to load user dataaaaa: ${response.reasonPhrase}');
    }
  }

  // Api xóa người dùng
 static Future<void> deleteUser(String username) async {
      var url = Uri.parse(
          'https://192.168.4.90:7074/api/auth/admin/userdeletepermanent');
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer eyJhbGciOiJodHRwOi8vd3d3LnczLm9yZy8yMDAxLzA0L3htbGRzaWctbW9yZSNobWFjLXNoYTI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOiIxNzA4Njc0NTQ1IiwidWlkIjoic3VwZXJhZG1pbiIsInVzZXJpZCI6IjY0NmRlMmVlZjk1OWIzYjhmN2JkM2IxMCIsImV4cCI6IjIxNDc0ODM2NDciLCJpc3MiOiJ2SllJWHZFVTUybWNTbE5SN01QbG9KMFowaU1QeFp4czF6Qk9oUjljWVVFPSIsImF1ZCI6InZKWUlYdkVVNTJtY1NsTlI3TVBsb0owWjBpTVB4WnhzMXpCT2hSOWNZVUU9IiwiYWNsIjp7fX0.8dv7a5Y1wBrZsip0jVp3rkQcKisKOlEsFtby1L5dFTk',
      };
      var requestBody = {
        "uid": username,
      };

      var response = await http.post(
          url,
          headers: headers,
          body: json.encode(requestBody)
      );
      if (response.statusCode == 200) {
        var responseData = json.decode(utf8.decode(response.bodyBytes));
        return responseData;

      }
      else {
        print('Error from API: ${response.body}');
        throw Exception(
            'Failed to send question to API: ${response.reasonPhrase}');
      }
    }

  // Api thay đổi mật khẩu người dùng
  static Future<void> changePassword(String username, String password,String retypePassword) async {
    var url = Uri.parse(
        'https://192.168.4.90:7074/api/auth/admin/userchangepassword');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer eyJhbGciOiJodHRwOi8vd3d3LnczLm9yZy8yMDAxLzA0L3htbGRzaWctbW9yZSNobWFjLXNoYTI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOiIxNzA4NjgzMTY0IiwidWlkIjoic3VwZXJhZG1pbiIsInVzZXJpZCI6IjY1ZDg2Y2I1YWE1YmU4YjA5OWI3MWM2MCIsImV4cCI6IjIxNDc0ODM2NDciLCJpc3MiOiJ2SllJWHZFVTUybWNTbE5SN01QbG9KMFowaU1QeFp4czF6Qk9oUjljWVVFPSIsImF1ZCI6InZKWUlYdkVVNTJtY1NsTlI3TVBsb0owWjBpTVB4WnhzMXpCT2hSOWNZVUU9IiwiYWNsIjp7fX0.ASEb0DMEvAjXuJXDbjbJVgfqNkSGLl-aoGnvMRuOYJo',
    };
    var requestBody = {
      "uid": username,
      "pwd": password,
      "pwdRetype": retypePassword,
    };

    var response = await http.post(
        url,
        headers: headers,
        body: json.encode(requestBody)
    );
    if (response.statusCode == 200) {
      var responseData = json.decode(utf8.decode(response.bodyBytes));
      print('thay đổi thành công');
      return responseData;

    }
    else {
      print('Error from API: ${response.body}');
      throw Exception(
          'Failed to send question to API: ${response.reasonPhrase}');
    }
  }

  // Api thay đổi email người dùng
  static Future<void> changeEmail(String username, String email) async {
    var url = Uri.parse(
        'https://192.168.4.90:7074/api/auth/admin/userchangeemail');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer eyJhbGciOiJodHRwOi8vd3d3LnczLm9yZy8yMDAxLzA0L3htbGRzaWctbW9yZSNobWFjLXNoYTI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOiIxNzA4NDIxMTkwIiwidWlkIjoic3VwZXJhZG1pbiIsInVzZXJpZCI6IjY0NmRlMmVlZjk1OWIzYjhmN2JkM2IxMCIsImV4cCI6IjIxNDc0ODM2NDciLCJpc3MiOiJ2SllJWHZFVTUybWNTbE5SN01QbG9KMFowaU1QeFp4czF6Qk9oUjljWVVFPSIsImF1ZCI6InZKWUlYdkVVNTJtY1NsTlI3TVBsb0owWjBpTVB4WnhzMXpCT2hSOWNZVUU9IiwiYWNsIjp7fX0.O8UT-s647gR3cT0XYK6rpEAdMEKU1_tCz4G3W28umIw',
    };
    var requestBody = {
      "uid": username,
      "email": email,
    };

    var response = await http.post(
        url,
        headers: headers,
        body: json.encode(requestBody)
    );
    if (response.statusCode == 200) {
      var responseData = json.decode(utf8.decode(response.bodyBytes));
      print('thay đổi thành công');
      return responseData;
    }
    else {
      print('Error from API: ${response.body}');
      throw Exception(
          'Failed to send question to API: ${response.reasonPhrase}');
    }
  }

  // Api thay đổi số điện thoại người dùng
  static Future<void> changePhone(String username, String phone) async {
    var url = Uri.parse(
        'https://192.168.4.90:7074/api/auth/admin/userchangephone');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer eyJhbGciOiJodHRwOi8vd3d3LnczLm9yZy8yMDAxLzA0L3htbGRzaWctbW9yZSNobWFjLXNoYTI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOiIxNzA4NDIxMTkwIiwidWlkIjoic3VwZXJhZG1pbiIsInVzZXJpZCI6IjY0NmRlMmVlZjk1OWIzYjhmN2JkM2IxMCIsImV4cCI6IjIxNDc0ODM2NDciLCJpc3MiOiJ2SllJWHZFVTUybWNTbE5SN01QbG9KMFowaU1QeFp4czF6Qk9oUjljWVVFPSIsImF1ZCI6InZKWUlYdkVVNTJtY1NsTlI3TVBsb0owWjBpTVB4WnhzMXpCT2hSOWNZVUU9IiwiYWNsIjp7fX0.O8UT-s647gR3cT0XYK6rpEAdMEKU1_tCz4G3W28umIw',
    };
    var requestBody = {
      "uid": username,
      "phone": phone,
    };


    var response = await http.post(
        url,
        headers: headers,
        body: json.encode(requestBody)
    );
    if (response.statusCode == 200) {
      var responseData = json.decode(utf8.decode(response.bodyBytes));
      print('thay đổi thành công');
      return responseData;

    }
    else {
      print('Error from API: ${response.body}');
      throw Exception(
          'Failed to send question to API: ${response.reasonPhrase}');
    }
  }

  // Api thay đổi ảnh đại diện người dùng
  static Future<void> changeAvatarUrl(String username, String avatarUrl) async {
    var url = Uri.parse(
        'https://192.168.4.90:7074/api/auth/admin/userchangeavatarurl');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer eyJhbGciOiJodHRwOi8vd3d3LnczLm9yZy8yMDAxLzA0L3htbGRzaWctbW9yZSNobWFjLXNoYTI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOiIxNzA4NjgzMTY0IiwidWlkIjoic3VwZXJhZG1pbiIsInVzZXJpZCI6IjY1ZDg2Y2I1YWE1YmU4YjA5OWI3MWM2MCIsImV4cCI6IjIxNDc0ODM2NDciLCJpc3MiOiJ2SllJWHZFVTUybWNTbE5SN01QbG9KMFowaU1QeFp4czF6Qk9oUjljWVVFPSIsImF1ZCI6InZKWUlYdkVVNTJtY1NsTlI3TVBsb0owWjBpTVB4WnhzMXpCT2hSOWNZVUU9IiwiYWNsIjp7fX0.ASEb0DMEvAjXuJXDbjbJVgfqNkSGLl-aoGnvMRuOYJo',
    };
    var requestBody = {
      "uid": username,
      "avatarUrl": avatarUrl,
    };


    var response = await http.post(
        url,
        headers: headers,
        body: json.encode(requestBody)
    );
    if (response.statusCode == 200) {
      var responseData = json.decode(utf8.decode(response.bodyBytes));
      print('thay đổi thành công');
      return responseData;

    }
    else {
      print('Error from API: ${response.body}');
      throw Exception(
          'Failed to send question to API: ${response.reasonPhrase}');
    }
  }
  static Future<void> uploadImage(File file, String username) async {
    var url = Uri.parse('http://118.70.117.208:5141/api/uploadfiles/upload');

    var request = http.MultipartRequest('POST', url);
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        filename: 'img.jpg',
      ),
    );
    request.fields['username'] = username;

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        print('Image uploaded successfully');
      } else {
        print('Failed to upload image. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error uploading image: $error');
    }
  }
  }
class User {
  final String username;
  final String password;
  final String email;
  final String phoneNumber;
  final String avatarUrl;
  final int activated;
  final String id;
  final int createdAt;
  final int updatedAt;

  User({
    required this.username,
    required this.password,
    required this.email,
    required this.phoneNumber,
    required this.avatarUrl,
    required this.activated,
    required this.id,
    required this.createdAt,
    required this.updatedAt,

  });
  String getUsername() => username;
  String getPassword() => password;
  String getEmail() => email;
  String getPhoneNumber() => phoneNumber;
  String getAvatarUrl() => avatarUrl;
  int getActivated() => activated;
  String getId() => id;
  int getCreatedAt() => createdAt;
  int getUpdatedAt() => updatedAt;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      password: json['password'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      avatarUrl: json['avatarUrl'],
      activated: json['activated'],
      id: json['id'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
