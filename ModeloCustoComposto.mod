int T = ...;
range horizontePlanejamento = 1..T;

int quantidadeViagem = ...;
range rangeViagens = 1..quantidadeViagem;

int quantidadeCentrais = ...;
range rangeCentrais = 1..quantidadeCentrais;

int quantidadeTiposConcreto = ...;
range rangeTiposConcreto = 1..quantidadeTiposConcreto;

int quantidadeTiposCimento = ...;
range rangeTiposCimento = 1..quantidadeTiposCimento;

int quantidadeTiposAdicoes = ...;
range rangeTiposAdicoes = 1..quantidadeTiposAdicoes;

int quantidadeTiposAreia = ...;
range rangeTiposAreia = 1..quantidadeTiposAreia;

int quantidadeTiposBrita = ...;
range rangeTiposBrita = 1..quantidadeTiposBrita;

int quantidadeTiposAditivos = ...;
range rangeTiposAditivos = 1..quantidadeTiposAditivos;

int HorarioViagem[rangeViagens][horizontePlanejamento] = ...;

int VolumeConcretoViagem[rangeTiposConcreto][rangeViagens] = ...;

int CustoRodoviarioViagemCentral[rangeViagens][rangeCentrais] = ...;

float quantidadeCimentoConcreto[rangeTiposConcreto][rangeTiposCimento] = ...;
float quantidadeAdicaoConcreto[rangeTiposConcreto][rangeTiposAdicoes] = ...;
float quantidadeAreiaConcreto[rangeTiposConcreto][rangeTiposAreia] = ...;
float quantidadeBritaConcreto[rangeTiposConcreto][rangeTiposBrita] = ...;
float quantidadeAditivosConcreto[rangeTiposConcreto][rangeTiposAditivos] = ...;

