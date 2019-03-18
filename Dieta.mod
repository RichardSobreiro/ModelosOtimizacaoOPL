int qConcreto = ...; // Quantidade de tipos de concreto 
int qPeriodo = ...; // Quantidade de dias de planejamento
int qPontosCarga = ...; // Quantidade de pontos de carga
int qCimento = ...; // Quantidade de cimentos
int qAdicao = ...;
int qAgregadoMiudo = ...;
int qAgregadoGraudo = ...;
int qAgua = ...;
int qAditivo = ...;
int qMateriaisAdicionais = ...;

// Conjuntos
range C = 1..qConcreto;
range CT = 1..qCimento;
range AD = 1..qAdicao;
range AM = 1..qAgregadoMiudo;
range AG = 1..qAgregadoGraudo;
range A = 1..qAgua;
range AV = 1..qAditivo;
range MA = 1..qMateriaisAdicionais;
range T = 1..qPeriodo;
range P = 1..qPontosCarga;

// Parametros
float d[C][T] = ...; // Demanda do concreto c no dia t
float qc[CT][C] = ...; // Quantidade do cimento ct necess�ria para produzir um metro c�bico do concreto c
float qad[AD][C] = ...; // Quantidade da adi��o ad necess�ria para produzir um metro c�bico do concreto c
float qam[AM][C] = ...; // Quantidade da areia am necess�ria para produzir um metro c�bico do concreto c 
float qag[AG][C] = ...; // Quantidade da brita ag necess�ria para produzir um metro c�bico do concreto c
float qa[A][C] = ...;  // Quantidade da �gua a necess�ria para produzir um metro c�bico do concreto c
float qav[AV][C] = ...; // Quantidade do aditivo av necess�rio para produzir um metro c�bico do concreto c
float qma[MA][C] = ...; // Quantidade do material adicional ma necess�rio para produzir um metro c�bico do concreto c
float cqc[CT][P][T] = ...; // Custo do metro c�bico do cimento ct no ponto de carga p
float cqad[AD][P][T] = ...; // Custo unit�rio da adi��o ad no ponto de carga p
float cqam[AM][P][T] = ...; // Custo unit�rio da areia am no ponto de carga p 
float cqag[AG][P][T] = ...; // Custo unit�rio da brita ag no ponto de carga p
float cqa[A][P][T] = ...;  // Custo unit�rio da �gua a no ponto de carga p
float cqav[AV][P][T] = ...; // Custo unit�rio do aditivo av no ponto de carga p
float cqma[MA][P][T] = ...; // Custo unit�rio do material adicional ma no ponto de carga p 

// Vari�veis
dvar float xc[C][P][T]; // Quantidade de cimento c a ser comprada no ponto de carga p no dia t
dvar float xad[AD][P][T]; // Quantidade de adi��o ad a ser comprada no ponto de carga p no dia t
dvar float xam[AM][P][T]; // Quantidade de areia am a ser comprada no ponto de carga p no dia t
dvar float xag[AG][P][T]; // Quantidade de brita ag a ser comprada no ponto de carga p no dia t
dvar float xa[A][P][T]; // Quantidade de �gua a a ser comprada no ponto de carga p no dia t
dvar float xav[AV][P][T]; // Quantidade de aditivo av a ser comprada no ponto de carga p no dia t
dvar float xma[MA][P][T]; // Quantidade de material adicional ma a ser comprada no ponto de carga p no dia t
 
dvar float ec[C][T]; // Estoque do cimento c no per�odo t
dvar float ead[AD][P][T]; // Estoque de adi��o ad no ponto de carga p no dia t
dvar float eam[AM][P][T]; // Estoque de areia am no ponto de carga p no dia t
dvar float eag[AG][P][T]; // Estoque de brita ag no ponto de carga p no dia t
dvar float ea[A][P][T]; // Estoque de �gua a no ponto de carga p no dia t
dvar float eav[AV][P][T]; // Estoque de aditivo av no ponto de carga p no dia t
dvar float ema[MA][P][T]; // Estoque de material adicional ma no ponto de carga p no dia t

dvar float c[C][P][T]; // Custo do metro c�bico do concreto ct no ponto de carga p no dia t

// Modelo
