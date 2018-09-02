package App::OpenQA::Reporter::Mojo;
use 5.008001;
use strict; use warnings;
use feature 'say';
use utf8;

use Mojolicious::Lite;

get '/' => sub {
  my $c = shift;

  my $data = iron->man->get_data();
  my $needles = %{ $data }{needles};
  my $texts = %{ $data }{texts};
  my $invalid = %{ $data }{invalid};
  my $pass = 0;
  my $failure = 0;
  my $unknown = 0;

  for (keys %{ $needles }) {
    $pass += %{ $needles }{$_}->get_result('pass');
    $failure += %{ $needles }{$_}->get_result('failure');
    $unknown += %{ $needles }{$_}->get_result('unknown');
  }

  for (keys %{ $texts }) {
    $pass += %{ $texts }{$_}->get_result('pass');
    $failure += %{ $texts }{$_}->get_result('failure');
    $unknown += %{ $texts }{$_}->get_result('unknown');
  }

  $c->render(
    template => 'index',
    pass => $pass,
    failure => $failure,
    unknown => $unknown,
    invalid => $invalid,
  );
};

get '/needles' => sub {
  my $c = shift;
  my $data = iron->man->get_data();
  my $needles = %{ $data }{needles};

  $c->stash(
    'needles' => $needles,
  );
  $c->render(
    template => 'needles',
    'num' => scalar(keys(%{ $needles }))
  );
};

get '/texts' => sub {
  my $c = shift;
  my $data = iron->man->get_data();
  my $texts = %{ $data }{texts};

  $c->stash(
    'texts' => $texts,
  );
  $c->render(
    template => 'texts',
    'num' => scalar(keys(%{ $texts }))
  );
};

get '/files' => sub {
  my $c = shift;
  my $data = iron->man->get_data();
  my $resources = %{ $data }{resources};

  $c->stash(
    'resources' => $resources,
  );
  $c->render(
    template => 'files',
    'num' => scalar(@{ $resources })
  );
};

__DATA__

@@ index.html.ep
<!DOCTYPE html>
<html>
<head lang='en'>
    <meta charset='UTF-8'>
    <title>OpenQA Reports</title>
    <meta name='description' content='descrip'>
    <meta name='keywords' content='keywords'>
    <meta name='author' content='author'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <link rel='stylesheet' href='css/css_reset.css'>
    <link rel='stylesheet' href='http://fonts.googleapis.com/css?family=Droid+Sans:400'>
    <link rel='stylesheet' href='css/app.css'>
    <link rel='stylesheet' href='css/flyout_button.css'>
    <link rel='stylesheet' href='css/flyout_menu.css'>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css" integrity="sha384-MCw98/SFnGE8fJT3GXwEOngsV7Zt27NXFoaoApmYm81iuXoPkFOJwJ8ERdknLPMO" crossorigin="anonymous">
    <link rel='shortcut icon' href='img/favicon.ico'>
</head>

<body>

<!--
**********************************
SIDEBAR
**********************************
-->

<aside class="sidebar" id="sidebar" style="z-index: 9999;">
    <nav class="menu-items">
        <ul>
            <li><a href="#">Home</a></li>
            <li><a href="/needles">Needles</a></li>
            <li><a href="/texts">Texts</a></li>
            <li><a href="/files">Files/URL</a></li>
        </ul>
    </nav>


    <!--
    **********************************
    HAMBURGER
    **********************************
    -->
    <div id="hamburger" class="hamburglar menu-open-button">

        <div class="burger-icon">
            <div class="burger-container">
                <span class="burger-bun-top"></span>
                <span class="burger-filling"></span>
                <span class="burger-bun-bot"></span>
            </div>
        </div>

        <!-- svg ring containter -->
        <div class="burger-ring">
            <svg class="svg-ring">
                <path class="path" fill="none" stroke="#000" stroke-miterlimit="10" stroke-width="4"
                      d="M 34 2 C 16.3 2 2 16.3 2 34 s 14.3 32 32 32 s 32 -14.3 32 -32 S 51.7 2 34 2"/>
            </svg>
        </div>
        <!-- the masked path that animates the fill to the ring -->

        <svg width="0" height="0">
            <mask id="mask">
                <path xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000" stroke-miterlimit="10"
                      stroke-width="4" d="M 34 2 c 11.6 0 21.8 6.2 27.4 15.5 c 2.9 4.8 5 16.5 -9.4 16.5 h -4"/>
            </mask>
        </svg>
        <div class="path-burger">
            <div class="animate-path">
                <div class="path-rotation"></div>
            </div>
        </div>

    </div>

    <!--
    **********************************
    HAMBURGER END
    **********************************
    -->
</aside>

<!--
**********************************
SIDEBAR END
**********************************
-->
<div class="container-fluid" style="display: inline-flex;">

    <div class="display-2, center" style="width: 100%; margin-top: 25px; text-align: center;">
      <h2>OpenQA Reports</h2>

      <p class="lead text-muted">
        Web GUI that reports results of Needles or Text matches.
      </p>


      <div class="row" style="
          margin-top: 25px;
          text-align:  center;
          width: 90%;
          display: inline-flex;
        ">

        <div class="col-sm, cell" style="background: lightgreen;">
          <p class="lead cell-number" style="color: white;">
            <%= $pass %>
          </p>
          <p class="cell-text">
            Pass
          </>
        </div>

        <div class="col-sm, cell" style="background: red;">
          <p class="lead cell-number" style="color: white;">
            <%= $failure %>
          </p>
          <p class="cell-text">
            Failure
          </>
        </div>

        <div class="col-sm, cell" style="background: #c3c3c3;">
          <p class="lead cell-number" style="color: white;">
            <%= $unknown %>
          </p>
          <p class="cell-text">
            Unknown
          </>
        </div>
      </div>

      <div class="lead text-muted">
        Skipped objects <%= $invalid %>.
      <div>
    </div>

</div>

<script src='scripts/flyout_menu.js' async></script>
<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js" integrity="sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49" crossorigin="anonymous"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js" integrity="sha384-ChfqqxuZUCnJSK3+MXmPNIyE6ZbWh2IMqE241rYiqJxyMiZ6OW/JmZQ5stwEULTy" crossorigin="anonymous"></script>
</body>
</html>


@@ needles.html.ep
<!DOCTYPE html>
<html>
<head lang='en'>
    <meta charset='UTF-8'>
    <title>OpenQA Reports</title>
    <meta name='description' content='descrip'>
    <meta name='keywords' content='keywords'>
    <meta name='author' content='author'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <link rel='stylesheet' href='css/css_reset.css'>
    <link rel='stylesheet' href='http://fonts.googleapis.com/css?family=Droid+Sans:400'>
    <link rel='stylesheet' href='css/app.css'>
    <link rel='stylesheet' href='css/flyout_button.css'>
    <link rel='stylesheet' href='css/flyout_menu.css'>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css" integrity="sha384-MCw98/SFnGE8fJT3GXwEOngsV7Zt27NXFoaoApmYm81iuXoPkFOJwJ8ERdknLPMO" crossorigin="anonymous">
    <link rel='shortcut icon' href='img/favicon.ico'>
</head>

<body>

<!--
**********************************
SIDEBAR
**********************************
-->

<aside class="sidebar" id="sidebar" style="z-index: 9999;">
    <nav class="menu-items">
        <ul>
            <li><a href="/">Home</a></li>
            <li><a href="/needles">Needles</a></li>
            <li><a href="/texts">Texts</a></li>
            <li><a href="/files">Files/URL</a></li>
        </ul>
    </nav>


    <!--
    **********************************
    HAMBURGER
    **********************************
    -->
    <div id="hamburger" class="hamburglar menu-open-button">

        <div class="burger-icon">
            <div class="burger-container">
                <span class="burger-bun-top"></span>
                <span class="burger-filling"></span>
                <span class="burger-bun-bot"></span>
            </div>
        </div>

        <!-- svg ring containter -->
        <div class="burger-ring">
            <svg class="svg-ring">
                <path class="path" fill="none" stroke="#000" stroke-miterlimit="10" stroke-width="4"
                      d="M 34 2 C 16.3 2 2 16.3 2 34 s 14.3 32 32 32 s 32 -14.3 32 -32 S 51.7 2 34 2"/>
            </svg>
        </div>
        <!-- the masked path that animates the fill to the ring -->

        <svg width="0" height="0">
            <mask id="mask">
                <path xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000" stroke-miterlimit="10"
                      stroke-width="4" d="M 34 2 c 11.6 0 21.8 6.2 27.4 15.5 c 2.9 4.8 5 16.5 -9.4 16.5 h -4"/>
            </mask>
        </svg>
        <div class="path-burger">
            <div class="animate-path">
                <div class="path-rotation"></div>
            </div>
        </div>

    </div>

    <!--
    **********************************
    HAMBURGER END
    **********************************
    -->
</aside>

<!--
**********************************
SIDEBAR END
**********************************
-->
<div class="container-fluid" style="display: inline-flex;">

    <div class="display-2, center" style="width: 100%; margin-top: 25px; text-align: center;">
      <h2>Needles ( #<%= $num %> )</h2>

      </br>
      <table class="table">
        <thead>
          <tr>
            <th scope="col">Screenshot</th>
            <th scope="col"># Files</th>
            <th scope="col">Pass</th>
            <th scope="col">Failure</th>
            <th scope="col">Unknown</th>
            <th scope="col">Max needles</th>
          </tr>
        </thead>
        <tbody>
          % for my $k ( sort keys (%{ stash('needles') }) ) {
            <tr>
              <th>
                <%= $k %>
              </th>
              <th>
                <%= %{ stash('needles') }{$k}->get_result('n_files'); %>
              </th>
              <th>
                <%= %{ stash('needles') }{$k}->get_result('pass'); %>
              </th>
              <th>
                <%= %{ stash('needles') }{$k}->get_result('failure'); %>
              </th>
              <th>
                <%= %{ stash('needles') }{$k}->get_result('unknown'); %>
              </th>
              <th>
                <%= %{ stash('needles') }{$k}->get_result('max_needles'); %>
              </th>
            </tr>
          % }
        </tbody>
      </table>
    </div>

</div>

<script src='scripts/flyout_menu.js' async></script>
<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js" integrity="sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49" crossorigin="anonymous"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js" integrity="sha384-ChfqqxuZUCnJSK3+MXmPNIyE6ZbWh2IMqE241rYiqJxyMiZ6OW/JmZQ5stwEULTy" crossorigin="anonymous"></script>
</body>
</html>


@@ texts.html.ep

<!DOCTYPE html>
<html>
<head lang='en'>
    <meta charset='UTF-8'>
    <title>OpenQA Reports</title>
    <meta name='description' content='descrip'>
    <meta name='keywords' content='keywords'>
    <meta name='author' content='author'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <link rel='stylesheet' href='css/css_reset.css'>
    <link rel='stylesheet' href='http://fonts.googleapis.com/css?family=Droid+Sans:400'>
    <link rel='stylesheet' href='css/app.css'>
    <link rel='stylesheet' href='css/flyout_button.css'>
    <link rel='stylesheet' href='css/flyout_menu.css'>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css" integrity="sha384-MCw98/SFnGE8fJT3GXwEOngsV7Zt27NXFoaoApmYm81iuXoPkFOJwJ8ERdknLPMO" crossorigin="anonymous">
    <link rel='shortcut icon' href='img/favicon.ico'>
</head>

<body>

<!--
**********************************
SIDEBAR
**********************************
-->

<aside class="sidebar" id="sidebar" style="z-index: 9999;">
    <nav class="menu-items">
        <ul>
            <li><a href="/">Home</a></li>
            <li><a href="/needles">Needles</a></li>
            <li><a href="/texts">Texts</a></li>
            <li><a href="/files">Files/URL</a></li>
        </ul>
    </nav>


    <!--
    **********************************
    HAMBURGER
    **********************************
    -->
    <div id="hamburger" class="hamburglar menu-open-button">

        <div class="burger-icon">
            <div class="burger-container">
                <span class="burger-bun-top"></span>
                <span class="burger-filling"></span>
                <span class="burger-bun-bot"></span>
            </div>
        </div>

        <!-- svg ring containter -->
        <div class="burger-ring">
            <svg class="svg-ring">
                <path class="path" fill="none" stroke="#000" stroke-miterlimit="10" stroke-width="4"
                      d="M 34 2 C 16.3 2 2 16.3 2 34 s 14.3 32 32 32 s 32 -14.3 32 -32 S 51.7 2 34 2"/>
            </svg>
        </div>
        <!-- the masked path that animates the fill to the ring -->

        <svg width="0" height="0">
            <mask id="mask">
                <path xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000" stroke-miterlimit="10"
                      stroke-width="4" d="M 34 2 c 11.6 0 21.8 6.2 27.4 15.5 c 2.9 4.8 5 16.5 -9.4 16.5 h -4"/>
            </mask>
        </svg>
        <div class="path-burger">
            <div class="animate-path">
                <div class="path-rotation"></div>
            </div>
        </div>

    </div>

    <!--
    **********************************
    HAMBURGER END
    **********************************
    -->
</aside>

<!--
**********************************
SIDEBAR END
**********************************
-->
<div class="container-fluid" style="display: inline-flex;">

    <div class="display-2, center" style="width: 100%; margin-top: 25px; text-align: center;">
      <h2>Texts ( #<%= $num %> )</h2>

      </br>
      <table class="table">
        <thead>
          <tr>
            <th scope="col">Text</th>
            <th scope="col"># Files</th>
            <th scope="col">Pass</th>
            <th scope="col">Failure</th>
            <th scope="col">Unknown</th>
          </tr>
        </thead>
        <tbody>
          % for my $k ( sort keys (%{ stash('texts') }) ) {
            <tr>
              <th>
                <%= $k %>
              </th>
              <th>
                <%= %{ stash('texts') }{$k}->get_result('n_files'); %>
              </th>
              <th>
                <%= %{ stash('texts') }{$k}->get_result('pass'); %>
              </th>
              <th>
                <%= %{ stash('texts') }{$k}->get_result('failure'); %>
              </th>
              <th>
                <%= %{ stash('texts') }{$k}->get_result('unknown'); %>
              </th>
            </tr>
          % }
        </tbody>
      </table>
    </div>

</div>

<script src='scripts/flyout_menu.js' async></script>
<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js" integrity="sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49" crossorigin="anonymous"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js" integrity="sha384-ChfqqxuZUCnJSK3+MXmPNIyE6ZbWh2IMqE241rYiqJxyMiZ6OW/JmZQ5stwEULTy" crossorigin="anonymous"></script>
</body>
</html>

@@ files.html.ep

<!DOCTYPE html>
<html>
<head lang='en'>
    <meta charset='UTF-8'>
    <title>OpenQA Reports</title>
    <meta name='description' content='descrip'>
    <meta name='keywords' content='keywords'>
    <meta name='author' content='author'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <link rel='stylesheet' href='css/css_reset.css'>
    <link rel='stylesheet' href='http://fonts.googleapis.com/css?family=Droid+Sans:400'>
    <link rel='stylesheet' href='css/app.css'>
    <link rel='stylesheet' href='css/flyout_button.css'>
    <link rel='stylesheet' href='css/flyout_menu.css'>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css" integrity="sha384-MCw98/SFnGE8fJT3GXwEOngsV7Zt27NXFoaoApmYm81iuXoPkFOJwJ8ERdknLPMO" crossorigin="anonymous">
    <link rel='shortcut icon' href='img/favicon.ico'>
</head>

<body>

<!--
**********************************
SIDEBAR
**********************************
-->

<aside class="sidebar" id="sidebar" style="z-index: 9999;">
    <nav class="menu-items">
        <ul>
            <li><a href="/">Home</a></li>
            <li><a href="/needles">Needles</a></li>
            <li><a href="/texts">Texts</a></li>
            <li><a href="/files">Files/URL</a></li>
        </ul>
    </nav>


    <!--
    **********************************
    HAMBURGER
    **********************************
    -->
    <div id="hamburger" class="hamburglar menu-open-button">

        <div class="burger-icon">
            <div class="burger-container">
                <span class="burger-bun-top"></span>
                <span class="burger-filling"></span>
                <span class="burger-bun-bot"></span>
            </div>
        </div>

        <!-- svg ring containter -->
        <div class="burger-ring">
            <svg class="svg-ring">
                <path class="path" fill="none" stroke="#000" stroke-miterlimit="10" stroke-width="4"
                      d="M 34 2 C 16.3 2 2 16.3 2 34 s 14.3 32 32 32 s 32 -14.3 32 -32 S 51.7 2 34 2"/>
            </svg>
        </div>
        <!-- the masked path that animates the fill to the ring -->

        <svg width="0" height="0">
            <mask id="mask">
                <path xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000" stroke-miterlimit="10"
                      stroke-width="4" d="M 34 2 c 11.6 0 21.8 6.2 27.4 15.5 c 2.9 4.8 5 16.5 -9.4 16.5 h -4"/>
            </mask>
        </svg>
        <div class="path-burger">
            <div class="animate-path">
                <div class="path-rotation"></div>
            </div>
        </div>

    </div>

    <!--
    **********************************
    HAMBURGER END
    **********************************
    -->
</aside>

<!--
**********************************
SIDEBAR END
**********************************
-->
<div class="container-fluid" style="display: inline-flex;">

    <div class="display-2, center" style="width: 100%; margin-top: 25px; text-align: center;">
      <h2>Resources ( #<%= $num %> )</h2>

      </br>
      <table class="table">
        <thead>
          <tr>
            <th scope="col">Type</th>
            <th scope="col">Resource</th>
            <th scope="col">Errors</th>
            <th scope="col">Invalid</th>
          </tr>
        </thead>
        <tbody>
          % for my $r ( @{ stash('resources') } )  {
            <tr>
              <th>
                <%= $r->get_type(); %>
              </th>
              <th>
                <%= $r->get_type() eq 'file' ? $r->get_file() : $r->get_url(); %>
              </th>
              <th>
                % if (defined($r->get_error())) {
                  <div title="<%= $r->get_error();  %>" data-toggle="tooltip">Y</div>
                % } else {
                  <div>N</div>
                % }
              </th>
              <th>
                <%= $r->get_invalid(); %>
              </th>
            </tr>
          % }
        </tbody>
      </table>
    </div>

</div>
<script src='scripts/flyout_menu.js' async></script>
<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js" integrity="sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49" crossorigin="anonymous"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js" integrity="sha384-ChfqqxuZUCnJSK3+MXmPNIyE6ZbWh2IMqE241rYiqJxyMiZ6OW/JmZQ5stwEULTy" crossorigin="anonymous"></script>
<script>
  $(document).ready({
    $('[data-toggle="tooltip"]').tooltip();
  });
</script>
</body>
</html>

