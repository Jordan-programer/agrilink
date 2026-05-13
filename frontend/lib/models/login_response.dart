class LoginResponse {
  final String token;
  final String id;
  final String nome;
  final String telefone;

  LoginResponse({required this.token, required this.id, required this.nome, required this.telefone});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      id: json['id'],
      nome: json['nome'],
      telefone: json['telefone'],
    );
  }
}
