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

Category.create_if_new('design', 'Design')
Category.create_if_new('ux', 'Usabilidade')
Category.create_if_new('content', 'Conteúdo')
Category.create_if_new('design', 'Design')
Category.create_if_new('development', 'Programação')
Category.create_if_new('front-end-dev', 'Front-End')
Category.create_if_new('back-end-dev', 'Back-End')