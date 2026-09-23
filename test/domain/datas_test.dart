import 'package:flutter_test/flutter_test.dart';
import 'package:move_challenge/domain/datas.dart';

void main() {
  group('datas', () {
    test('gera chave com zeros à esquerda', () {
      expect(chaveData(DateTime(2026, 3, 5)), '2026-03-05');
    });

    test('soma dias atravessando mês e ano', () {
      expect(somarDias('2026-01-31', 1), '2026-02-01');
      expect(somarDias('2026-12-31', 1), '2027-01-01');
      expect(somarDias('2026-03-01', -1), '2026-02-28');
      expect(somarDias('2028-03-01', -1), '2028-02-29');
    });

    test('calcula primeiro e último dia do mês', () {
      expect(primeiroDiaDoMes('2026-09-22'), '2026-09-01');
      expect(ultimoDiaDoMes('2026-09-22'), '2026-09-30');
      expect(ultimoDiaDoMes('2026-02-10'), '2026-02-28');
    });

    test('escreve a data por extenso em português', () {
      expect(dataPorExtenso(DateTime(2026, 9, 22)), 'Terça-feira, 22 de setembro');
      expect(dataCompleta(DateTime(2026, 10, 1)), '1 de outubro de 2026');
      expect(mesPorExtenso(DateTime(2026, 9)), 'Setembro 2026');
    });
  });
}
