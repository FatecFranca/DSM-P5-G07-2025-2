import 'dart:ffi';
import 'package:PetDex/data/enums/species.dart';
import 'package:intl/intl.dart';


class Animal {
  final String id;
  final String nome;
  final DateTime dataNascimento;
  final String sexo;
  final double peso;
  final bool castrado;
  final String raca;
  final SpeciesEnum especie;

  Animal({
    required this.id,
    required this.nome,
    required this.dataNascimento,
    required this.sexo,
    required this.peso,
    required this.castrado,
    required this.raca,
    required this.especie,
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'],
      nome: json['nome'],
      dataNascimento: DateTime.parse(json['dataNascimento']),
      sexo: json['sexo'],
      peso: (json['peso'] as num).toDouble(),
      castrado: json['castrado'],
      raca: json['racaNome'],
      especie: json['especieNome'].toLowerCase() == 'gato'
          ? SpeciesEnum.cat
          : SpeciesEnum.dog,
    );
  }
}