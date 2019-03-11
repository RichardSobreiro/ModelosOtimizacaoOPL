// ----------------------------------------------------------------------------------------------------------------------
// Parametros
int M = ...;
int T = ...;
int quantidadeObras = ...;
int quantidadeViagem = ...;
int quantidadeCentrais = ...;
int quantidadeTipoMaterial = ...;
// ----------------------------------------------------------------------------------------------------------------------
// Definicao dos ranges
range horizontePlanejamento = 1..T;
range rangeObra = 1..quantidadeObras;
range rangeViagem = 1..quantidadeViagem;
range rangeCentrais = 1..quantidadeCentrais;
range rangeTipoMaterial = 1..quantidadeTipoMaterial;
// ----------------------------------------------------------------------------------------------------------------------
// Parametros
int CaminhoesPorCentral[rangeCentrais] = ...;
int BombasPorCentral[rangeCentrais] = ...;
float HorarioChegadaViagemObra[rangeViagem][rangeObra] = ...;
float TempoMedioTrajetoCentralObraIda[rangeObra][rangeCentrais] = ...;

float TempoMedioTrajetoCentralObraVolta[rangeCentrais][rangeObra] = ...;
float TempoMedioDescargaObra[rangeObra] = ...;
float CustoRodoviarioObraCentral[rangeObra][rangeCentrais] = ...;
float CustoAtrasoSaidaCentral[rangeViagem] = ...;
float CustoAtrasoSaidaObra[rangeViagem] = ...;
float CustoMaterialViagemObraCentral[rangeViagem][rangeObra][rangeCentrais] = ...;
int MaterialObraDisponivelCentral[rangeTipoMaterial][rangeObra];
// ----------------------------------------------------------------------------------------------------------------------
// Variaveis
dvar boolean x[rangeViagem][rangeObra][rangeCentrais];
dvar float MaiorCustoTotal;

dvar int horaPesagemViagem[rangeViagem][rangeObra];
dvar int atrasoSaidaCentral[rangeViagem][rangeObra];
dvar int horaSaidaCentral[rangeViagem][rangeObra];
dvar int atrasoSaidaObra[rangeViagem][rangeObra];
dvar int horaSaidaObra[rangeViagem][rangeObra];
dvar int horaChegadaCentral[rangeViagem][rangeObra];

dvar boolean horaPesagemMenorOuIgualHoraAtual[horizontePlanejamento][rangeViagem];
dvar boolean horaChegadaCentralMaiorOuIgualHoraAtual[horizontePlanejamento][rangeViagem];
dvar boolean caminhaoEmUsoNaCentral[rangeViagem][horizontePlanejamento][rangeCentrais];
// ----------------------------------------------------------------------------------------------------------------------
minimize MaiorCustoTotal;
	
subject to {
	CustoAtendimentoViagem:
		MaiorCustoTotal >= 
			sum(i in rangeViagem, j in rangeObra, k in rangeCentrais)( 
				x[i][j][k] * (CustoRodoviarioObraCentral[j][k] + CustoMaterialViagemObraCentral[i][j][k]) +
			 	(atrasoSaidaCentral[i][j] * CustoAtrasoSaidaCentral[i]) + 
			 	(atrasoSaidaObra[i][j] * CustoAtrasoSaidaObra[i])
			);
	UmaViagemSoPodeSerAtendidaPorNoMaximoUmaCentral:
	forall(i in rangeViagem, j in rangeObra){
		sum(k in rangeCentrais)(x[i][j][k]) <= 1;
		sum(k in rangeCentrais)(x[i][j][k]) >= 1;	
	}
	
	HoraSaidaCentralMenorQueHoraSolicitadaPeloCliente:
	forall(i in rangeViagem, j in rangeObra, k in rangeCentrais){
		horaSaidaCentral[i][j] + atrasoSaidaCentral[i][j] + 
			TempoMedioTrajetoCentralObraIda[i][j] - HorarioChegadaViagemObra[i][j] <= M * (1 - x[i][j][k]);	
	}
	
	HoraSaidaObraMaiorQueHoraSolicidataPeloCliente:
	forall(i in rangeViagem, j in rangeObra, k in rangeCentrais){
		HorarioChegadaViagemObra[i][j] + TempoMedioDescargaObra[j] + atrasoSaidaObra[i][j] - horaSaidaObra[i][j] 
			<=  M * (1 - x[i][j][k]); 
	}
	
	HoraChegadaCentralMaiorHoraSaidaObra:
	forall(i in rangeViagem, j in rangeObra, k in rangeCentrais){
		horaSaidaObra[i][j] + TempoMedioTrajetoCentralObraVolta[i][j] - horaChegadaCentral[i][j] 
			<=  M * (1 - x[i][j][k]);
	}
	
	SeCentralAtendeViagem_E_PesagemAnteriorMomentoAtual_E_RetornoCentralMaiorMomentoAtual_CaminhaoEmUso:
	forall(i in rangeViagem, j in rangeObra, k in rangeCentrais, t in horizontePlanejamento){
		horaPesagemViagem[i][j] - i <= M * (1 - horaPesagemMenorOuIgualHoraAtual[i][j]);
		i - horaChegadaCentral[j] <= M * (1 - horaChegadaCentralMaiorOuIgualHoraAtual[i][j]);
		forall(k in rangeCentrais){
			horaPesagemMenorOuIgualHoraAtual[i][j] + horaChegadaCentralMaiorOuIgualHoraAtual[i][j] + x[j][k] 
				>= 3 * (1 - caminhaoEmUsoNaCentral[i][j][k]);
		}
	}
	
}
