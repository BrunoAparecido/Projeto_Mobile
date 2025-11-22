class ParametroGetDto {
  String atributoPesquisa;
  int comparador;
  String valorPesquisa;

  ParametroGetDto({
    required this.atributoPesquisa,
    required this.comparador,
    required this.valorPesquisa,
  });

  Map<String, dynamic> toJson() {
    return {
      "atributoPesquisa": atributoPesquisa,
      "comparador": comparador,
      "valorPesquisa": valorPesquisa,
    };
  }
}