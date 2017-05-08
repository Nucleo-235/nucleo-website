# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Partner.create_if_new('Lucas Cordeiro', 'Sócio Designer, Artista, Skatista entre outros', '')
Partner.create_if_new('Henrique Rangel', 'Sócio Programador, Geek e corredor', '')
Customer.create_if_new('Mariana Pellicciari', 'Cliente, parceira, amante da sustentabilidade na moda', '')
Customer.create_if_new('Victor Morganti', 'Cliente, Parceiro, inquieto, "hacker de vida" ...', '')
Customer.create_if_new('Bruno Bertozzo', 'Arquiteto, "cientista" de futebol, jogador, amigo, cliente e até programador nas horas vagas', 'Sempre acelerado com as coisas que gosta, não é a toa que o Bruno e outros dois amigos começaram o <a href="#fut-rank">Fut Rank</a>, um dos primeiros projetos da nucleo, daqueles que da orgulho de participar. Mas ele não para daqui a pouco já inventa um negócio novo ou uma novidade nos que já tem!')
Customer.create_if_new('Edu Polati', 'Engenheiro, totalmente moderno e a frente, parceiro, e amante de automobilismo', 'O Edu e a nucleo começaram essa parceria graças a uma conexão de familia, para ajudarmos com a <a href="#powerburst">Powerburst</a>. Foi assim, com almoços - teoricamente reuniões - que vimos o quanto humano, "a frente" e de papo bom (fora todas outras qualidades compartilhadas por outros engenheiros) é o Edu.')
Customer.create_if_new('Leandro Aliseda', 'Empresário e empreendedor, estudante, filósofo e visionário', 'Leandro é daqueles cara que o papo flui, fala bem, sabe das coisas que está falando. Uma das pessoas que tem uma visão clara do que quer e espera do futuro, e consegue analisar como chegar lá, tanto pra ele, quanto pra quem está a sua volta. Uma das inspirações e influências para a nucleo voltar a estudar (filosofia e novas maneiras de negócios), além de ter projetos disruptivos como o [Sense Flux](http://senseflux.com/) e o <a href="#papo-reto">Papo Reto</a>, esse último feito com a nucleo.')
Customer.create_if_new('Ruy Galvão', 'Empresário, moderno, sempre ligado, além de baterista e palmeirense nas demais horas', 'Ruy tem a visão que falta para muitos empresários aqui nas terras tupiniquins, é a pessoa que vai sempre conseguir analisar tudo de maneira macro, não esquecendo de ser moderno, para atingir seus objetivos, ouvindo a todos ao redor mas sempre pesando sua visão. Graças a um cruzamento de indicações aproximamos nossos caminhos que resultou numa parceria sensacional para o <a href="#gauss">site da Gauss</a>, empresa que é CEO.')
Customer.create_if_new('Fábio Pontes', 'Programador old school mas moderno, sério mas brincalhão, corinthiano que não liga pra futebol, ô gerente!', 'Fábio, ou "lokomia", foi o gerente durante anos de um dos sócios da nucleo, que teve paciência pra aguentar, ensinar e ajudar, e que também liberou e possibilitou o "padawan" para abrir a própria empresa. Hoje, além de toda a parceria, é cliente da nucleo com projetos web focados em arquitetura, como o <a href="#ofcdesk-connect-website">Connect</a>, além de sempre topar um café no meio da tarde no escritório. O cara mais gente boa que um funcionário pode querer como "chefe" ou colega.')
Customer.create_if_new('Marcellus Palma', 'Parceiro, vendedor nato, pilhado, carioca em Sampa, gamer e ultra moderno', 'Aquele carioca em Sampa que não sofre preconceito algum, fala olhando no olho, que num piscar de olhos já teria conseguido te vender algo. Tem uma empresa de advergames, surfando na crista da onda, a Eeze, que tivemos o orgulho de participar. Um cara que dá sempre pra contar, de acertar prazos e custos até jogar um CS a noite.')

Category.create_if_new('design', 'Design')
Category.create_if_new('ux', 'Usabilidade')
Category.create_if_new('content', 'Conteúdo')
Category.create_if_new('development', 'Programação')
Category.create_if_new('front-end-dev', 'Front-End')
Category.create_if_new('back-end-dev', 'Back-End')
Category.create_if_new('mobile', 'Apps p Celular')
Category.create_if_new('website', 'Website')
Category.create_if_new('system', 'Sistema')
Category.create_if_new('intranet', 'Intranet')
Category.create_if_new('template', 'Tema Pronto')