package controller

import (
	"e-grid/models"
	"net/http"

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"
)

func GetController(c *fiber.Ctx, db *gorm.DB) error{
	var record []models.EnergyRecord

	if err := db.Find(&record).Error; err != nil {
		return c.Status(http.StatusBadRequest).SendString(err.Error())
	}
	return c.Status(http.StatusOK).JSON(record)
}

func PostController(c *fiber.Ctx, db *gorm.DB) error{
	var newRecord models.EnergyRecord
	if err := c.BodyParser(&newRecord); err != nil{
		return c.Status(http.StatusBadRequest).SendString(err.Error())
	}
	if err := db.Create(&newRecord).Error; err != nil{
		c.Status(http.StatusBadRequest).SendString(err.Error())
	
	}
	return c.Status(http.StatusOK).JSON(newRecord)
}

// func PutController(c *fiber.Ctx, db *gorm.DB) error{
// 	return c.Status(http.StatusOK).SendString("get all data")
// }

// func DeleteController(c *fiber.Ctx, db *gorm.DB) error{
// 	return c.Status(http.StatusOK).SendString("get all data")
// }


