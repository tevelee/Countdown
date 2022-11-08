import ArgumentParser

@main
struct Countdown: AsyncParsableCommand {
    static var configuration = CommandConfiguration(abstract: "A solver utility for the Countdown letters/numbers game",
                                                    subcommands: [
                                                        NumbersCommand.self,
                                                        LettersCommand.self,
                                                        ConondrumsCommand.self
                                                    ])
}
