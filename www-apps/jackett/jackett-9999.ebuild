EAPI=8

USE_DOTNET="net6.0"
DOTNET_PKG_COMPAT="6.0"
NUGET_API="https://api.nuget.org/v3/flat2"

NUGETS="
AngleSharp@1.1.2
AngleSharp.Xml@1.0.0
Autofac@6.5.0
Autofac.Extensions.DependencyInjection@8.0.0
AutoMapper@10.1.1
BencodeNET@4.0.0
CommandLineParser@2.9.1
coverlet.msbuild@3.2.0
DotNet4.SocksProxy@1.4.0.1
FlareSolverrSharp@3.0.7
FluentAssertions@6.8.0
Microsoft.AspNetCore@2.2.0
Microsoft.AspNetCore.Antiforgery@2.2.0
Microsoft.AspNetCore.Authentication@2.2.0
Microsoft.AspNetCore.Authentication.Abstractions@2.2.0
Microsoft.AspNetCore.Authentication.Cookies@2.2.0
Microsoft.AspNetCore.Authentication.Core@2.2.0
Microsoft.AspNetCore.Authorization@2.2.0
Microsoft.AspNetCore.Authorization.Policy@2.2.0
Microsoft.AspNetCore.Connections.Abstractions@2.2.0
Microsoft.AspNetCore.Cors@2.2.0
Microsoft.AspNetCore.Cryptography.Internal@2.2.0
Microsoft.AspNetCore.Cryptography.Internal@6.0.28
Microsoft.AspNetCore.DataProtection@2.2.0
Microsoft.AspNetCore.DataProtection@6.0.28
Microsoft.AspNetCore.DataProtection.Abstractions@2.2.0
Microsoft.AspNetCore.DataProtection.Abstractions@6.0.28
Microsoft.AspNetCore.Diagnostics@2.2.0
Microsoft.AspNetCore.Diagnostics.Abstractions@2.2.0
Microsoft.AspNetCore.HostFiltering@2.2.0
Microsoft.AspNetCore.Hosting@2.2.0
Microsoft.AspNetCore.Hosting.Abstractions@2.2.0
Microsoft.AspNetCore.Hosting.Server.Abstractions@2.2.0
Microsoft.AspNetCore.Html.Abstractions@2.2.0
Microsoft.AspNetCore.Http@2.2.2
Microsoft.AspNetCore.Http.Abstractions@2.2.0
Microsoft.AspNetCore.Http.Extensions@2.2.0
Microsoft.AspNetCore.Http.Features@2.2.0
Microsoft.AspNetCore.HttpOverrides@2.2.0
Microsoft.AspNetCore.JsonPatch@2.2.0
Microsoft.AspNetCore.JsonPatch@6.0.28
Microsoft.AspNetCore.Localization@2.2.0
Microsoft.AspNetCore.Mvc@2.2.0
Microsoft.AspNetCore.Mvc.Abstractions@2.2.0
Microsoft.AspNetCore.Mvc.Analyzers@2.2.0
Microsoft.AspNetCore.Mvc.ApiExplorer@2.2.0
Microsoft.AspNetCore.Mvc.Core@2.2.0
Microsoft.AspNetCore.Mvc.Cors@2.2.0
Microsoft.AspNetCore.Mvc.DataAnnotations@2.2.0
Microsoft.AspNetCore.Mvc.Formatters.Json@2.2.0
Microsoft.AspNetCore.Mvc.Localization@2.2.0
Microsoft.AspNetCore.Mvc.NewtonsoftJson@6.0.28
Microsoft.AspNetCore.Mvc.Razor@2.2.0
Microsoft.AspNetCore.Mvc.Razor.Extensions@2.2.0
Microsoft.AspNetCore.Mvc.RazorPages@2.2.0
Microsoft.AspNetCore.Mvc.TagHelpers@2.2.0
Microsoft.AspNetCore.Mvc.ViewFeatures@2.2.0
Microsoft.AspNetCore.Razor@2.2.0
Microsoft.AspNetCore.Razor.Design@2.2.0
Microsoft.AspNetCore.Razor.Language@2.2.0
Microsoft.AspNetCore.Razor.Runtime@2.2.0
Microsoft.AspNetCore.ResponseCaching.Abstractions@2.2.0
Microsoft.AspNetCore.ResponseCompression@2.2.0
Microsoft.AspNetCore.Rewrite@2.2.0
Microsoft.AspNetCore.Routing@2.2.0
Microsoft.AspNetCore.Routing.Abstractions@2.2.0
Microsoft.AspNetCore.Server.IIS@2.2.0
Microsoft.AspNetCore.Server.IISIntegration@2.2.0
Microsoft.AspNetCore.Server.Kestrel@2.2.0
Microsoft.AspNetCore.Server.Kestrel.Core@2.2.0
Microsoft.AspNetCore.Server.Kestrel.Https@2.2.0
Microsoft.AspNetCore.Server.Kestrel.Transport.Abstractions@2.2.0
Microsoft.AspNetCore.Server.Kestrel.Transport.Sockets@2.2.0
Microsoft.AspNetCore.StaticFiles@2.2.0
Microsoft.AspNetCore.WebUtilities@2.2.0
Microsoft.Bcl.AsyncInterfaces@6.0.0
Microsoft.Bcl.TimeProvider@8.0.0
Microsoft.CodeAnalysis.Analyzers@1.1.0
Microsoft.CodeAnalysis.Common@2.8.0
Microsoft.CodeAnalysis.CSharp@2.8.0
Microsoft.CodeAnalysis.Razor@2.2.0
Microsoft.CodeCoverage@17.4.1
Microsoft.CSharp@4.7.0
Microsoft.DiaSymReader.Native@1.7.0
Microsoft.DotNet.PlatformAbstractions@2.1.0
Microsoft.Extensions.Caching.Abstractions@2.2.0
Microsoft.Extensions.Caching.Memory@2.2.0
Microsoft.Extensions.Configuration@2.2.0
Microsoft.Extensions.Configuration@6.0.1
Microsoft.Extensions.Configuration.Abstractions@2.2.0
Microsoft.Extensions.Configuration.Abstractions@6.0.0
Microsoft.Extensions.Configuration.Binder@2.2.0
Microsoft.Extensions.Configuration.CommandLine@2.2.0
Microsoft.Extensions.Configuration.EnvironmentVariables@2.2.0
Microsoft.Extensions.Configuration.FileExtensions@2.2.0
Microsoft.Extensions.Configuration.Json@2.2.0
Microsoft.Extensions.Configuration.UserSecrets@2.2.0
Microsoft.Extensions.DependencyInjection@2.2.0
Microsoft.Extensions.DependencyInjection@6.0.0
Microsoft.Extensions.DependencyInjection.Abstractions@2.2.0
Microsoft.Extensions.DependencyInjection.Abstractions@6.0.0
Microsoft.Extensions.DependencyModel@2.1.0
Microsoft.Extensions.FileProviders.Abstractions@2.2.0
Microsoft.Extensions.FileProviders.Abstractions@6.0.0
Microsoft.Extensions.FileProviders.Composite@2.2.0
Microsoft.Extensions.FileProviders.Physical@2.2.0
Microsoft.Extensions.FileSystemGlobbing@2.2.0
Microsoft.Extensions.Hosting.Abstractions@2.2.0
Microsoft.Extensions.Hosting.Abstractions@6.0.0
Microsoft.Extensions.Localization@2.2.0
Microsoft.Extensions.Localization.Abstractions@2.2.0
Microsoft.Extensions.Logging@2.2.0
Microsoft.Extensions.Logging@6.0.0
Microsoft.Extensions.Logging.Abstractions@2.2.0
Microsoft.Extensions.Logging.Abstractions@6.0.0
Microsoft.Extensions.Logging.Abstractions@6.0.4
Microsoft.Extensions.Logging.Configuration@2.2.0
Microsoft.Extensions.Logging.Console@2.2.0
Microsoft.Extensions.Logging.Debug@2.2.0
Microsoft.Extensions.Logging.EventSource@2.2.0
Microsoft.Extensions.ObjectPool@2.2.0
Microsoft.Extensions.Options@2.2.0
Microsoft.Extensions.Options@6.0.0
Microsoft.Extensions.Options.ConfigurationExtensions@2.2.0
Microsoft.Extensions.Primitives@2.2.0
Microsoft.Extensions.Primitives@6.0.0
Microsoft.Extensions.WebEncoders@2.2.0
Microsoft.NETCore.Platforms@1.1.0
Microsoft.NETCore.Platforms@5.0.0
Microsoft.NETFramework.ReferenceAssemblies@1.0.3
Microsoft.NETFramework.ReferenceAssemblies.net462@1.0.3
Microsoft.Net.Http.Headers@2.2.0
Microsoft.NET.Test.Sdk@17.4.1
Microsoft.TestPlatform.ObjectModel@17.4.1
Microsoft.TestPlatform.TestHost@17.4.1
Microsoft.Win32.Registry@4.5.0
Microsoft.Win32.Registry@5.0.0
MimeMapping@1.0.1.50
Mono.Posix@7.1.0-final.1.21458.1
Mono.Unix@7.1.0-final.1.21458.1
MSTest.TestAdapter@3.0.2
MSTest.TestFramework@3.0.2
NETStandard.Library@2.0.3
Newtonsoft.Json@13.0.1
Newtonsoft.Json@13.0.3
Newtonsoft.Json.Bson@1.0.1
Newtonsoft.Json.Bson@1.0.2
NLog@5.1.2
NLog.Extensions.Logging@5.2.1
NLog.Web.AspNetCore@5.2.1
NuGet.Frameworks@5.11.0
NUnit@3.13.3
NUnit3TestAdapter@4.3.1
NUnit.ConsoleRunner@3.16.1
Polly@8.3.1
Polly.Core@8.3.1
Selenium.Chrome.WebDriver@85.0.0
Selenium.WebDriver@4.7.0
SharpZipLib@1.4.2
System.AppContext@4.3.0
System.Buffers@4.5.0
System.Buffers@4.5.1
System.Collections@4.3.0
System.Collections.Concurrent@4.3.0
System.Collections.Immutable@1.5.0
System.ComponentModel.Annotations@4.5.0
System.Configuration.ConfigurationManager@4.4.0
System.Console@4.3.0
System.Diagnostics.Debug@4.3.0
System.Diagnostics.DiagnosticSource@4.7.1
System.Diagnostics.DiagnosticSource@6.0.0
System.Diagnostics.EventLog@6.0.0
System.Diagnostics.FileVersionInfo@4.3.0
System.Diagnostics.StackTrace@4.3.0
System.Diagnostics.Tools@4.3.0
System.Dynamic.Runtime@4.3.0
System.Formats.Asn1@6.0.0
System.Globalization@4.3.0
System.IO.Compression@4.3.0
System.IO.FileSystem@4.3.0
System.IO.FileSystem.AccessControl@5.0.0
System.IO.FileSystem.Primitives@4.3.0
System.IO.Pipelines@4.6.0
System.IO.Pipelines@5.0.1
System.Linq@4.3.0
System.Linq.Expressions@4.3.0
System.Memory@4.5.1
System.Memory@4.5.4
System.Numerics.Vectors@4.5.0
System.Reflection@4.3.0
System.Reflection.Emit@4.7.0
System.Reflection.Emit.ILGeneration@4.7.0
System.Reflection.Metadata@1.6.0
System.Resources.ResourceManager@4.3.0
System.Runtime@4.3.0
System.Runtime.CompilerServices.Unsafe@6.0.0
System.Runtime.Extensions@4.3.0
System.Runtime.InteropServices@4.3.0
System.Runtime.InteropServices.RuntimeInformation@4.3.0
System.Runtime.Numerics@4.3.0
System.Security.AccessControl@5.0.0
System.Security.AccessControl@6.0.0
System.Security.Cryptography.Algorithms@4.3.0
System.Security.Cryptography.Cng@4.5.0
System.Security.Cryptography.Encoding@4.3.0
System.Security.Cryptography.Pkcs@6.0.1
System.Security.Cryptography.Primitives@4.3.0
System.Security.Cryptography.ProtectedData@6.0.0
System.Security.Cryptography.X509Certificates@4.3.0
System.Security.Cryptography.Xml@4.5.0
System.Security.Cryptography.Xml@6.0.1
System.Security.Permissions@4.5.0
System.Security.Principal.Windows@5.0.0
System.ServiceProcess.ServiceController@6.0.1
System.Text.Encoding@4.3.0
System.Text.Encoding.CodePages@6.0.0
System.Text.Encoding.Extensions@4.3.0
System.Text.Encodings.Web@6.0.0
System.Text.Json@6.0.9
System.Threading@4.3.0
System.Threading.Tasks@4.3.0
System.Threading.Tasks.Extensions@4.5.4
System.Threading.Tasks.Parallel@4.3.0
System.Threading.Thread@4.3.0
System.ValueTuple@4.5.0
System.Xml.ReaderWriter@4.3.0
System.Xml.XDocument@4.3.0
System.Xml.XmlDocument@4.3.0
System.Xml.XPath@4.3.0
System.Xml.XPath.XDocument@4.3.0
YamlDotNet@13.1.1
"

inherit dotnet-pkg
DESCRIPTION="Jackett works as a proxy server: it translates queries from apps (Sonarr, Radarr, SickRage, CouchPotato, Mylar3, Lidarr, DuckieTV, qBittorrent, Nefarious etc.) into tracker-site-specific http queries, parses the html or json response, and then sends results back to the requesting software. This allows for getting recent uploads (like RSS) and performing searches. Jackett is a single repository of maintained indexer scraping & translation logic - removing the burden from other apps."
HOMEPAGE="https://github.com/Jackett/Jackett"

if [[ ${PV} == *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/Jackett/Jackett"
else
	SRC_URI="https://github.com/Jackett/Jackett/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

SRC_URI+=" ${NUGET_URIS} "

RESTRICT="mirror"
LICENSE="GPL-3"
SLOT="0"
IUSE=""

S="${WORKDIR}/${P}/src"
DOTNET_PKG_BAD_PROJECTS=("${S}/Jackett.Service" "${S}/Jackett.Tray")
DOTNET_PKG_PROJECTS=("${S}/Jackett.Server")

BDEPEND="${RDEPEND}"
RDEPEND="virtual/dotnet-sdk:6.0
         dev-lang/mono"

DEPEND="${RDEPEND}"

src_unpack() {
	dotnet-pkg_src_unpack

	if [[ -n "${EGIT_REPO_URI}" ]]; then
		git-r3_src_unpack
	fi
}

src_configure() {
	dotnet-pkg_src_configure
}

src_prepare() {
	dotnet-pkg_src_prepare
}

pkg_setup() {
	dotnet-pkg_pkg_setup
}

src_compile() {
	dotnet-pkg_src_compile
}

src_install() {
	for dir in /home/*; do
		if [ ! -d "${dir}/.config/systemd" ]; then
			dodir "${dir}/.config/systemd"
			dodir "${dir}/.config/systemd/user"
		fi
		insinto "${dir}/.config/systemd/user"
		newins "${FILESDIR}/jackett.service" "jackett.service"
	done

	dotnet-pkg_src_install

}

pkg_postinstall() {
	einfo "Jackett has been installed to /opt/jackett"
	einfo "To start the service run: systemctl --user start jackett"
	einfo "To enable the service to start on boot run: systemctl --user enable jackett"
	einfo "To access the web interface go to: http://localhost:9117"
	einfo "To configure Jackett go to: http://localhost:9117/Admin/Dashboard"
	einfo "For more information see: https://github.com/Jackett/Jackett"
}
