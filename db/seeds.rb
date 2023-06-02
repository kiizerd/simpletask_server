# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
user = User.create(email: 'guest@simpletask.com', password: 'password')

project = Project.create(title: 'SimpleTask project manager', description: '', user_id: user.id)
sections =
  Section.create(
    [{ name: 'client', project: }, { name: 'server', project: }]
  )

tasks =
  Task.create(
    [
      { name: 'Build frontend', section: sections.first, project: },
      { name: 'Build backend', section: sections.last, project: }
    ]
  )
