"""Package the local source preview extension without npm or network access."""
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED
import json

root = Path(__file__).resolve().parent.parent
source = root / 'editor/math-source-preview'
package = json.loads((source / 'package.json').read_text())
destination = root / 'cache/math-source-preview.vsix'
destination.parent.mkdir(parents=True, exist_ok=True)
manifest = f'''<?xml version="1.0" encoding="utf-8"?>
<PackageManifest Version="2.0.0" xmlns="http://schemas.microsoft.com/developer/vsx-schema/2011">
 <Metadata><Identity Language="en-US" Id="{package['name']}" Version="{package['version']}" Publisher="{package['publisher']}"/>
 <DisplayName>{package['displayName']}</DisplayName><Description xml:space="preserve">Render LaTeX equations in the native editor.</Description>
 <Properties><Property Id="Microsoft.VisualStudio.Code.Engine" Value="^1.85.0"/>
 <Property Id="Microsoft.VisualStudio.Code.ExtensionDependencies" Value="james-yu.latex-workshop"/>
 <Property Id="Microsoft.VisualStudio.Code.ExtensionKind" Value="workspace"/></Properties></Metadata>
 <Installation><InstallationTarget Id="Microsoft.VisualStudio.Code"/></Installation>
 <Dependencies/><Assets><Asset Type="Microsoft.VisualStudio.Code.Manifest" Path="extension/package.json" Addressable="true"/></Assets>
</PackageManifest>'''
with ZipFile(destination, 'w', ZIP_DEFLATED) as archive:
    archive.writestr('extension.vsixmanifest', manifest)
    archive.writestr('[Content_Types].xml', '''<?xml version="1.0" encoding="utf-8"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
<Default Extension="json" ContentType="application/json"/>
<Default Extension="js" ContentType="application/javascript"/>
<Default Extension="md" ContentType="text/markdown"/>
<Default Extension="vsixmanifest" ContentType="text/xml"/>
</Types>''')
    for path in source.iterdir():
        if path.is_file() and path.suffix in {'.js', '.json', '.md'}:
            archive.write(path, f'extension/{path.name}')
print(destination)
