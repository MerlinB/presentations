import os
import subprocess
import tempfile

from slugify import slugify

title = input("Titel des Vortrags:")

path = input("Pfad zu Vortrag:")
while not os.path.exists(path):
    path = input(f"Keine Datei bei {path} gefunden. Pfad zu Vortrag:")

cut = 0
presentation_path = None
presentation = input("Präsentation vorhanden? [Y]") or 'Y'
presentation = True if presentation in ['Y', 'y', 'Yes', 'yes'] else False
if presentation:
    presentation_path = input("Pfad zu Präsentation:")
    while not os.path.exists(presentation_path):
        presentation_path = input(f"Keine Datei bei {path} gefunden. Pfad zu Präsentation:")

    cut = int(input("Sekunden vom Anfang der Präsentation zu schneiden: [0]") or 0)

with tempfile.TemporaryDirectory() as tmp_dir:
    intro_path = f'{tmp_dir}/Intro_{slugify(title)}.mp4'

    subprocess.run([
        'ffmpeg', '-y', '-loop', '1',
        '-t', '11', '-i', 'scholarium_logo.png',
        '-i', 'Intro.mp3',
        '-filter_complex',
        ';'.join([
            'color=white@0:1920x1080,format=yuva444p[c]',
            '[c]split[c1][c2]',
            '[0:v]scale=1000:-1[logo]',
            '[logo]fade=in:st=0.5:d=3:alpha=1,fade=out:st=8:d=2:alpha=1[ovr1]',
            f'[c1]drawtext=fontsize=55:fontfile=garamond_regular.otf:text={title}:x=(w-text_w)/2:y=H/2,fade=in:st=2:d=2:alpha=1,fade=out:st=8:d=2:alpha=1[ovr2]',
            '[c2][ovr1]overlay=W/2-w/2:H/3-h/2:shortest=1[out1]',
            '[out1][ovr2]overlay=0:0:shortest=1[out2]']),
        '-map', '[out2]', '-map', '1:a',
        '-c:v', 'libx265', '-preset', 'fast',
        intro_path
    ])

    if presentation:
        subprocess.run([
            'ffmpeg', '-y', '-t', '10',
            '-i', path,
            '-ss', str(cut), '-i', presentation_path,
            '-i', intro_path,
            '-filter_complex',
            ';'.join([
                '[1]crop=iw*0.96:ih*0.9:iw*0.02:ih*0.1[c]',
                '[c]scale=-1:1080[s]',
                '[2]scale=1920:-1[i]',
                '[s]pad=1920:1080:0:0[v]',
                '[0]scale=800:-1[p]',
                '[v][p]overlay=x=W-w:y=H-h:shortest=1[out]',
                '[i][2:a][out][0:a]concat=n=2:v=1:a=1[video][audio]',
                '[audio]asplit[audio1][audio2]']),
            '-c:v', 'libx265', '-preset', 'fast', '-c:a', 'aac', '-b:a', '192k',
            '-map', '[video]', '-map', '[audio1]', f'{slugify(title)}.mp4',
            '-map', '[audio2]', f'{slugify(title)}.mp3'])
    else:
        subprocess.run([
            'ffmpeg', '-y', '-t', '10',
            '-i', path,
            '-i', intro_path,
            '-filter_complex',
            ';'.join([
                '[0]scale=-1:1080[s]',
                '[s]pad=1920:1080:ow/2-iw/2:0[v]',
                '[1]scale=1920:-1[i]',
                '[i][1:a][v][0:a]concat=n=2:v=1:a=1[video][audio]',
                '[audio]asplit[audio1][audio2]']),
            '-c:v', 'libx265', '-preset', 'fast', '-c:a', 'aac', '-b:a', '192k',
            '-map', '[video]', '-map', '[audio1]', f'{slugify(title)}.mp4',
            '-map', '[audio2]', f'{slugify(title)}.mp3'])
