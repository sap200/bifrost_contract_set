package main

import (
	"crypto/ed25519"
	"encoding/hex"
	"fmt"
	"log"
	"os"
)

const Fa12 = "send Fa12"
const BiTez = "send Mutez"

func main() {
	if len(os.Args) != 3 {
		fmt.Println("usage ./tezos-cosmos-signer [privateKey] [fa12/mutez]")
		log.Fatalln("code 1: Expected at least 1 argument")
	}

	if os.Args[2] != "fa12" && os.Args[2] != "mutez" {
		fmt.Println("usage ./tezos-cosmos-signer [privateKey] [fa12/mutez]")
		log.Fatalln("code1: Arg2 should be fa12 or mutez")
	}

	decision := os.Args[2]

	seed := os.Args[1]

	secKey := ed25519.NewKeyFromSeed([]byte(seed)[:32])
	fmt.Println("Generated Private key: " + hex.EncodeToString(secKey))

	var s []byte

	if decision == "fa12" {
		s = ed25519.Sign(secKey, []byte(Fa12))
		fmt.Println("Generated signature: " + hex.EncodeToString(s))
	} else if decision == "mutez" {
		s = ed25519.Sign(secKey, []byte(BiTez))
		fmt.Println("Generated signature: " + hex.EncodeToString(s))
	}

	hex := hex.EncodeToString(secKey[32:])
	fmt.Println("Generated Public Key: " + hex)

	// dummy verification
	fmt.Println("Dummy verification")
	if decision == "fa12" {
		isTrue := ed25519.Verify(secKey.Public().(ed25519.PublicKey), []byte(Fa12), s)
		fmt.Println(isTrue)
	} else if decision == "mutez" {
		isTrue := ed25519.Verify(secKey.Public().(ed25519.PublicKey), []byte(BiTez), s)
		fmt.Println(isTrue)
	}
}
