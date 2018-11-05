# frozen_string_literal: true

module Overcommit::Hook::PostCheckout
  class EnsureBranchName < Base
    def run
      return :pass if Overcommit::GitRepo.current_branch =~ /\A[a-z0-9_\/-]+\z/
      return :pass if Overcommit::GitRepo.current_branch.empty?

      [:fail,
       [
         ' ________________________________________           ',
         '/ INVALID BRANCH NAME                    \          ',
         '|                                        |          ',
         '| Git can get confused if there are      |          ',
         '| branch names with lower and upper case |          ',
         '| mixed. Please use lowercase branch     |          ',
         '\ names only.                            /          ',
         ' ----------------------------------------           ',
         '             \          __---__                     ',
         '                     _-       /--______             ',
         '                __--( /     \ )XXXXXXXXXXX\v.       ',
         '              .-XXX(   O   O  )XXXXXXXXXXXXXXX-     ',
         '             /XXX(       U     )        XXXXXXX\    ',
         '           /XXXXX(              )--_  XXXXXXXXXXX\  ',
         '          /XXXXX/ (      O     )   XXXXXX   \XXXXX\ ',
         '          XXXXX/   /            XXXXXX   \__ \XXXXX ',
         '          XXXXXX__/          XXXXXX         \__---->',
         '  ---___  XXX__/          XXXXXX      \__         / ',
         '    \-  --__/   ___/\  XXXXXX            /  ___--/= ',
         '     \-\    ___/    XXXXXX               --- XXXXXX ',
         '        \-\/XXX\ XXXXXX                      /XXXXX ',
         '          \XXXXXXXXX   \                    /XXXXX/ ',
         '           \XXXXXX      >                 _/XXXXX/  ',
         '             \XXXXX--__/              __-- XXXX/    ',
         '              -XXXXXXXX---------------  XXXXXX-     ',
         '                 \XXXXXXXXXXXXXXXXXXXXXXXXXX/       ',
         '                   ""VXXXXXXXXXXXXXXXXXXV""         ',
         "Invalid branch name: #{Overcommit::GitRepo.current_branch}"
       ].join("\n")]
    end
  end
end
