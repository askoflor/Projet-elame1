import 'dart:convert';
import 'dart:io';

void main() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
  print('Mock server listening on http://localhost:8080');

  final usersByEmail = <String, Map<String, dynamic>>{};
  final tokens = <String, Map<String, dynamic>>{};

  await for (HttpRequest request in server) {
    // CORS
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    request.response.headers.add('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.noContent;
      await request.response.close();
      continue;
    }

    final path = request.uri.path;
    try {
      if (path == '/api/v1/auth/register' && request.method == 'POST') {
        final body = await utf8.decoder.bind(request).join();
        final data = jsonDecode(body) as Map<String, dynamic>;
        final email = data['email'] as String? ?? '';
        final password = data['password'] as String? ?? '';
        final role = data['role'] as String? ?? 'CLIENT';

        if (email.isEmpty || password.isEmpty) {
          request.response.statusCode = HttpStatus.badRequest;
          request.response.write(jsonEncode({'message': 'Email et mot de passe requis'}));
          await request.response.close();
          continue;
        }

        if (usersByEmail.containsKey(email)) {
          request.response.statusCode = HttpStatus.conflict;
          request.response.write(jsonEncode({'message': 'Utilisateur déjà existant'}));
          await request.response.close();
          continue;
        }

        final user = {'id': usersByEmail.length + 1, 'email': email, 'role': role};
        usersByEmail[email] = {'password': password, 'user': user};
        final token = 'token-${email.hashCode}-${DateTime.now().millisecondsSinceEpoch}';
        tokens[token] = user;

        request.response.statusCode = HttpStatus.ok;
        request.response.write(jsonEncode({'token': token, 'user': user}));
        await request.response.close();
        continue;
      }

      if (path == '/api/v1/auth/login' && request.method == 'POST') {
        final body = await utf8.decoder.bind(request).join();
        final data = jsonDecode(body) as Map<String, dynamic>;
        final email = data['email'] as String? ?? '';
        final password = data['password'] as String? ?? '';

        final stored = usersByEmail[email];
        if (stored == null || stored['password'] != password) {
          request.response.statusCode = HttpStatus.unauthorized;
          request.response.write(jsonEncode({'message': 'Email ou mot de passe incorrect'}));
          await request.response.close();
          continue;
        }

        final user = stored['user'] as Map<String, dynamic>;
        final token = 'token-${email.hashCode}-${DateTime.now().millisecondsSinceEpoch}';
        tokens[token] = user;

        request.response.statusCode = HttpStatus.ok;
        request.response.write(jsonEncode({'token': token, 'user': user}));
        await request.response.close();
        continue;
      }

      if (path == '/api/v1/auth/logout' && request.method == 'POST') {
        final auth = request.headers.value('authorization');
        if (auth != null && auth.startsWith('Bearer ')) {
          final token = auth.substring(7);
          tokens.remove(token);
        }
        request.response.statusCode = HttpStatus.ok;
        request.response.write(jsonEncode({'message': 'Logged out'}));
        await request.response.close();
        continue;
      }

      if (path == '/api/v1/auth/me' && request.method == 'GET') {
        final auth = request.headers.value('authorization');
        if (auth == null || !auth.startsWith('Bearer ')) {
          request.response.statusCode = HttpStatus.unauthorized;
          request.response.write(jsonEncode({'message': 'Unauthorized'}));
          await request.response.close();
          continue;
        }
        final token = auth.substring(7);
        final user = tokens[token];
        if (user == null) {
          request.response.statusCode = HttpStatus.unauthorized;
          request.response.write(jsonEncode({'message': 'Unauthorized'}));
          await request.response.close();
          continue;
        }
        request.response.statusCode = HttpStatus.ok;
        request.response.write(jsonEncode(user));
        await request.response.close();
        continue;
      }

      // Not found
      request.response.statusCode = HttpStatus.notFound;
      request.response.write(jsonEncode({'message': 'Not found'}));
      await request.response.close();
    } catch (e, s) {
      stderr.writeln('Error handling request: $e\n$s');
      request.response.statusCode = HttpStatus.internalServerError;
      request.response.write(jsonEncode({'message': 'Internal server error'}));
      await request.response.close();
    }
  }
}
