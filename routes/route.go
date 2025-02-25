package routes

import (
	"e-grid/controller"

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"
)

func Handler(app *fiber.App, db *gorm.DB){
	app.Post("/", func (c *fiber.Ctx) error  {
		return controller.PostController(c, db)
	})

	app.Get("/", func (c *fiber.Ctx) error  {
		return controller.GetController(c, db)
	})

	// app.Put("/:id", func (c *fiber.Ctx) error  {
	// 	return controller.PutController(c, db)
	// })

	// app.Delete("/:id", func (c *fiber.Ctx) error  {
	// 	return controller.DeleteController(c, db)
	// })
}