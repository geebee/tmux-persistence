#!/usr/bin/env ruby

# Start - Configuration Variables
sessionDir = "~/.sessions"
maxStoredSessions = 5
filesToRoll = 3
# End - Configuration Variables

Dir::mkdir(sessionDir) unless File.exists?(sessionDir)

files = []
Dir.entries(sessionDir).each do |e|
  if e !~ /^\./
    files << e
  end
end
files.sort!

if files.length > maxStoredSessions
  0.upto(filesToRoll - 1) do |index|
    File.delete( sessionDir+ "/" + files[index] )
  end
  puts "Rotated stored sessions"
end

#%x[rm #{sessionDir}/*-restore]

sessions = %x[tmux list-sessions -F "\#{sessionName}"].split("\n")

sessions.each do |sessionName|
  rawPaneList = %x[tmux list-panes -t #{sessionName} -s -F "\#{windowIndex} \#{paneIndex} \#{windowWidth} \#{windowHeight} \#{paneWidth} \#{paneHeight} \#{window_name} \#{pane_current_path} \#{pane_pid}"].split("\n")

  panes = []
  rawPaneList.each do |pane_line|
    temp_pane = pane_line.split(" ")
    panes.push({
      windowIndex: Integer(temp_pane[0]),
      paneIndex: Integer(temp_pane[1]),
      windowWidth: Integer(temp_pane[2]),
      windowHeight: Integer(temp_pane[3]),
      paneWidth: Integer(temp_pane[4]),
      paneHeight: Integer(temp_pane[5]),
      window_name: temp_pane[6],
      cwd: temp_pane[7],
      pid: temp_pane[8]
    })
  end

  sessionScript = ""
  panes.each do |pane|
    pane[:cmd] = %x[ps --no-headers -o cmd --ppid #{pane[:pid]}].delete("\n")
    pane[:cmd] = %x[ps --no-headers -o cmd #{pane[:pid]}].delete("\n").gsub(/^-/,"") unless pane[:cmd] != ""

    sessionScript += "tmux new-window -t $SESSION -a -n #{pane[:window_name]} \"cd #{pane[:cwd]} && #{pane[:cmd]}\"\n"

    if pane[:paneIndex] > 0
      if pane[:paneWidth] < pane[:windowWidth]
        sessionScript += "tmux join-pane -h -l #{pane[:paneWidth]} -s $SESSION:#{pane[:windowIndex] +1}.0 -t $SESSION:#{pane[:windowIndex]}\n"
      else
        sessionScript += "tmux join-pane -v -l #{pane[:paneHeight]} -s $SESSION:#{pane[:windowIndex] +1}.0 -t $SESSION:#{pane[:windowIndex]}\n"
      end
    end
  end

  File.open("#{sessionDir}/#{sessionName}-restore","w") {|f| f.write(%Q[
    #!/usr/bin/env bash
    SESSION=#{sessionName}

    if [ -z $TMUX ]; then

      # if session already exists, attach
      tmux has-session -t $SESSION 
      if [ $? -eq 0 ]; then
        echo \"Session $SESSION already exists. Attaching...\"
        tmux attach -t $SESSION
        exit 0;
      fi

      # make new session
      tmux new-session -d -s $SESSION

    #{sessionScript}

      # attach to new session
      tmux select-window -t $SESSION:1
      tmux attach-session -t $SESSION

    fi
  ])}
end
