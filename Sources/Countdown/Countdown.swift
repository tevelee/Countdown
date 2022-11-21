import ArgumentParser

@main
struct Countdown: AsyncParsableCommand {
    static var configuration = CommandConfiguration(abstract: "A solver utility for the Countdown letters/numbers game",
                                                    subcommands: [
                                                        SolveCommand.self,
                                                        GenerateCommand.self,
                                                    ],
                                                    defaultSubcommand: SolveCommand.self)
}

struct SolveCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(commandName: "solve",
                                                    abstract: "A solver utility for the Countdown letters/numbers game",
                                                    subcommands: [
                                                        NumbersSolverCommand.self,
                                                        LettersSolverCommand.self,
                                                        ConondrumSolverCommand.self
                                                    ])
}

struct GenerateCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(commandName: "generate",
                                                    abstract: "A generator utility for the Countdown letters/numbers game",
                                                    subcommands: [
                                                        NumbersGeneratorCommand.self,
                                                        LettersGeneratorCommand.self,
                                                        ConondrumGeneratorCommand.self
                                                    ])
}

