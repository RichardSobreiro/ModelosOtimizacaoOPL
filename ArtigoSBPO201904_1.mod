int T = ...;
range horizontePlanejamento = 1..T;

int quantidadeViagem = ...;
range rangeViagem = 1..quantidadeViagem;

int quantidadeCentrais = ...;
range rangeCentrais = 1..quantidadeCentrais;

int quantidadeTiposConcreto = ...;
range rangeTiposConcreto = 1..quantidadeTiposConcreto;

float HorarioViagem[rangeViagem][horizontePlanejamento] = ...;

float VolumeConcretoViagem[rangeTiposConcreto][rangeViagem] = ...;

float CustoRodoviarioViagemCentral[rangeViagem][rangeCentrais] = ...;

float CustoM3ConcretoCentral[rangeTiposConcreto][rangeCentrais] = ...;

dvar bool x[rangeViagem][rangeCentral] = ...; 

minimize sum(i in rangeViagem, j in rangeCentral) {
	x[i][j] * (CustoRodoviarioViagemCentral[i][j] + 
		sum(k in rangeTiposConcreto) { 
		VolumeConcretoViagem[k][i] * CustoConcretoCentral[k][j];
	})
}