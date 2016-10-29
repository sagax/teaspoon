<html>
<head>
    <title><%= $message %></title>
</head>
<body>
    <h1><%= $message %></h1>
    <h2><%[ list hello hi cats ]%></h1>
    <h3><%[ yield blather ]%></h1>
    <ul>
        <%
            yield
            set stuff [list "The chase is better than the catch" a b c]

            foreach item $stuff {
                puts "<li>$item</li>"
            }

            yield 1
        %>
    </ul>
    <p>
        <%[ list poop ]%>
    </p>
</body>
</html>
