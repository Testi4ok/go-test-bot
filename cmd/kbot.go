package cmd

import (
	"fmt"
	"log"
	"os"
	"time"

	"github.com/joho/godotenv"
	"github.com/spf13/cobra"
	telebot "gopkg.in/telebot.v3"
)

// kbotCmd represents the kbot command
var kbotCmd = &cobra.Command{
	Use:   "kbot",
	Short: "A brief description of your command",
	Long: `A longer description that spans multiple lines and likely contains examples
and usage of using your command.`,
	Run: func(cmd *cobra.Command, args []string) {

		// Load .env file before reading env vars
		if err := godotenv.Load(); err != nil {
			log.Println("Warning: .env file not found")
		}

		// Get TELE_TOKEN from environment
		TeleToken := os.Getenv("TELE_TOKEN")
		if TeleToken == "" {
			log.Fatal("TELE_TOKEN is not set in environment or .env file")
		}

		fmt.Println("kbot started", appVersion)

		kbot, err := telebot.NewBot(telebot.Settings{
			Token:  TeleToken,
			Poller: &telebot.LongPoller{Timeout: 10 * time.Second},
		})
		if err != nil {
			log.Fatalf("Failed to create bot: %v", err)
			return
		}

		kbot.Handle(telebot.OnText, func(m telebot.Context) error {
			log.Print(m.Message().Payload, m.Text())
			payload := m.Message().Payload

			switch payload {
			case "hello":
				err = m.Send(fmt.Sprintf("Hello I'm kbot %s!", appVersion))
			}

			return nil
		})

		kbot.Start()
	},
}

func init() {
	rootCmd.AddCommand(kbotCmd)
}
