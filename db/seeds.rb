# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
project = Project.create(title: "SimpleTask project manager", description: "")
sections =
  Section.create(
    [{ name: "client", project: project }, { name: "server", project: project }]
  )

tasks =
  Task.create(
    [
      { name: "Build frontend", section: sections.first, project: project },
      { name: "Build backend", section: sections.last, project: project }
    ]
  )
