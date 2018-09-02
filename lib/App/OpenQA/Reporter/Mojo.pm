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
% layout 'default';
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

@@ needles.html.ep
% layout 'default';
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

@@ texts.html.ep
% layout 'default';
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

@@ files.html.ep
% layout 'default';
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

