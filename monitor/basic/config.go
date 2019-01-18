package basic

import (
	"encoding/json"
	"errors"
	"time"

	"github.com/elastos/Elastos.NET.Hive.Cluster/config"
)

const configKey = "monbasic"

// Default values for this Config.
const (
	DefaultCheckInterval = 15 * time.Second
)

// Config allows to initialize a Monitor and customize some parameters.
type Config struct {
	config.Saver

	CheckInterval time.Duration
}

type jsonConfig struct {
	CheckInterval string `json:"check_interval"`
}

// ConfigKey provides a human-friendly identifier for this type of Config.
func (cfg *Config) ConfigKey() string {
	return configKey
}

// Default sets the fields of this Config to sensible values.
func (cfg *Config) Default() error {
	cfg.CheckInterval = DefaultCheckInterval
	return nil
}

// Validate checks that the fields of this Config have working values,
// at least in appearance.
func (cfg *Config) Validate() error {
	if cfg.CheckInterval <= 0 {
		return errors.New("basic.check_interval too low")
	}
	return nil
}

// LoadJSON sets the fields of this Config to the values defined by the JSON
// representation of it, as generated by ToJSON.
func (cfg *Config) LoadJSON(raw []byte) error {
	jcfg := &jsonConfig{}
	err := json.Unmarshal(raw, jcfg)
	if err != nil {
		logger.Error("Error unmarshaling basic monitor config")
		return err
	}

	interval, _ := time.ParseDuration(jcfg.CheckInterval)
	cfg.CheckInterval = interval

	return cfg.Validate()
}

// ToJSON generates a human-friendly JSON representation of this Config.
func (cfg *Config) ToJSON() ([]byte, error) {
	jcfg := &jsonConfig{}

	jcfg.CheckInterval = cfg.CheckInterval.String()

	return json.MarshalIndent(jcfg, "", "    ")
}
