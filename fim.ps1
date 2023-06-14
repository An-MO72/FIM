
Write-Host ""
Write-Host "what would you like to do ?"
Write-Host  " A) Collecte new baseline."
Write-Host  " B) Begin monitoring files with saved Baseline."

$response = Read-Host -Prompt "Please enter 'A' or 'B' !"
Write-Host ""

Function Calcule-File-Hash($filepath){
    $filehash = Get-FileHash -Path $filepath -Algorithm SHA512
    return $filehash 
}

$target = "C:\Users\Mouhssine\Desktop\Cyber\projects\FIM"

if ( $response.ToUpper() -eq "A" ){
    # delete baseline.txt if it's already exist
        if (Test-Path $target\baseline.txt) {
            Remove-Item $target\baseline.txt
            }
    # calcule the hashs from the target files and store theme in baseline.txt

        # collect all files from the target folder
            $files = Get-ChildItem -Path $target\files

        # calculate the hash for each file and write it in baseline.txt
             foreach ( $f in $files ){
               $hash = Calcule-File-Hash $f.FullName
               "$($hash.Path)|$($hash.Hash)" | Out-File -FilePath $target\baseline.txt -Append
             }
             Write-Host "Baseline created !"

}
elseif( $response.ToUpper() -eq "B" ){
    # begin monitoring files with saved baseline
        # load path|hash from baseline.txt and store them in a dictionary
        $fileHashsDictionary = @{}
        $filesNames =  New-Object System.Collections.ArrayList # create an array to store files's names from the baseline
        $fileHashsAndPaths = Get-Content -Path $target/baseline.txt
        foreach ( $f in $fileHashsAndPaths ){
           $fileHashsDictionary[$f.Split('|')[0]] = $f.Split('|')[1]
           $t = $filesNames.Add($f.Split('|')[0])
        }
        
        while ($true){
            Start-Sleep -Seconds 1
            
            $files = Get-ChildItem -Path $target\files
           
            foreach ($f in $files){
                # check if a new file has been created 
                   if( $fileHashsDictionary[$f.FullName] -eq $null ){
                    Write-Host $f.FullName " has been created !" -ForegroundColor Blue
                   }
                   else{
                    # check if a file has been modified
                        $hash = Calcule-File-Hash $f.FullName
                        if ($hash.Hash -ne $fileHashsDictionary[$hash.Path]){
                            Write-Host  $f.FullName " has been modified ! " -ForegroundColor Yellow
                        }
                    # check if a file has been delted !
                        foreach ($n in $filesNames){
                            if( $n -notin $files.FullName){
                                Write-Host "$n has been deleted !" -ForegroundColor Red
                             }
                        }
                        

                        
                }
            }
        }       

}
