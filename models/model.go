package models

type EnergyRecord struct {
	UserID        int     `json:"user_id" gorm:"primaryKey"`
	UserType      string  `json:"usertype"`
	WalletAddress string  `json:"walletaddress"`
	EnergyBalance float64 `json:"energybalance"`
	EnergyAmount  float64 `json:"energyamount"`
	TotalCost     float64 `json:"totalcost"`
}