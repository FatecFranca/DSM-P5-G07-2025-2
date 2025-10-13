import 'dart:ffi';

import 'package:PetDex/data/enums/species.dart';
import 'package:intl/intl.dart';

class Animal {
  final String id;
  final String nome;
  final DateFormat dataNascimento;
  final String sexo;
  final Float peso;
  final Bool castrado;
  final String usuario;
  final String raca;
  final SpeciesEnum especie;

  Animal({
    required this.id,
    required this.nome,
    required this.dataNascimento,
    required this.sexo,
    required this.peso,
    required this.castrado,
    required this.usuario,
    required this.raca,
    required this.especie,
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'],
      nome: json['nome'],
      dataNascimento: json['dataNascimento'],
      sexo: json['sexo'],
      peso: json['peso'],
      castrado: json['castrado'],
      usuario: json['usuario'],
      raca: json['racaNome'],
      especie: json['especieNome'] == 'gato'
          ? SpeciesEnum.cat
          : SpeciesEnum.dog,
    );
  }
}
