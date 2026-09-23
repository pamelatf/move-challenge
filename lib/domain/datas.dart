/// Utilitários de data. As datas do app são guardadas como texto no
/// formato `aaaa-mm-dd`, o que permite comparar e ordenar como texto.
library;

String _doisDigitos(int n) => n.toString().padLeft(2, '0');

String chaveData(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${_doisDigitos(d.month)}-${_doisDigitos(d.day)}';

DateTime dataDaChave(String chave) {
  final partes = chave.split('-');
  return DateTime(
    int.parse(partes[0]),
    int.parse(partes[1]),
    int.parse(partes[2]),
  );
}

String hojeChave([DateTime? agora]) => chaveData(agora ?? DateTime.now());

String somarDias(String chave, int dias) {
  final d = dataDaChave(chave);
  return chaveData(DateTime(d.year, d.month, d.day + dias));
}

/// Retorna `aaaa-mm`.
String mesDaChave(String chave) => chave.substring(0, 7);

String primeiroDiaDoMes(String chave) => '${mesDaChave(chave)}-01';

String ultimoDiaDoMes(String chave) {
  final d = dataDaChave(chave);
  return chaveData(DateTime(d.year, d.month + 1, 0));
}

String maiorChave(String a, String b) => a.compareTo(b) >= 0 ? a : b;

const List<String> meses = [
  'janeiro',
  'fevereiro',
  'março',
  'abril',
  'maio',
  'junho',
  'julho',
  'agosto',
  'setembro',
  'outubro',
  'novembro',
  'dezembro',
];

/// Índice 0 = domingo (compatível com `DateTime.weekday % 7`).
const List<String> diasDaSemana = [
  'domingo',
  'segunda-feira',
  'terça-feira',
  'quarta-feira',
  'quinta-feira',
  'sexta-feira',
  'sábado',
];

const List<String> iniciaisDaSemana = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

String _primeiraMaiuscula(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// Ex.: "Terça-feira, 22 de setembro".
String dataPorExtenso(DateTime d) =>
    '${_primeiraMaiuscula(diasDaSemana[d.weekday % 7])}, ${d.day} de ${meses[d.month - 1]}';

/// Ex.: "1 de outubro de 2026".
String dataCompleta(DateTime d) =>
    '${d.day} de ${meses[d.month - 1]} de ${d.year}';

/// Ex.: "Setembro 2026".
String mesPorExtenso(DateTime d) =>
    '${_primeiraMaiuscula(meses[d.month - 1])} ${d.year}';
