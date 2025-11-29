import '../models/guild.dart';

class MockGuildData {
  static final List<Guild> guilds = [
    Guild(
      id: '1',
      name: 'NuSpettacl Clean Club',
      description: 'Admin a pulire le città. Tremate rifiuti',
      membersCount: 13,
    ),
    Guild(
      id: '2',
      name: 'EcoWarriors Salerno',
      description: 'Guerrieri contro la plastica e l\'inquinamento.',
      membersCount: 156,
    ),
    Guild(
      id: '3',
      name: 'Plastic Free Team',
      description: 'Riduciamo la plastica, un passo alla volta.',
      membersCount: 89,
    ),
    Guild(
      id: '4',
      name: 'Amici del Mare',
      description: 'Pulizia delle spiagge e tutela marina.',
      membersCount: 210,
    ),
    Guild(
      id: '5',
      name: 'PETWarriors',
      description: 'Ogni tappo fa la differenza.',
      membersCount: 12,
    ),
  ];
}