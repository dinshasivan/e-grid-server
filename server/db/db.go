package db

import (
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func Connect() (*gorm.DB, error){
	url := "postgres://admin:admin123@localhost:5433/egrid-postgres"

	db, err := gorm.Open(postgres.Open(url))

	return db, err
}