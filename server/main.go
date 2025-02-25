package main

import (
	"e-grid/db"
	"e-grid/models"
	"e-grid/routes"
	"log"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/logger"
)

func main(){
	db, err := db.Connect()

	if err != nil {
		log.Fatalln(err)
	}
	db.AutoMigrate(models.EnergyRecord{})
	app := fiber.New()
	app.Use(logger.New())
	routes.Handler(app,db)

	app.Listen(":8080")
}