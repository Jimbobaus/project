---
title: "A Data Science Approach to Forecast Electricity Consumption in Australia"
team: 22
session: Term 1, 2021
coursecode: MATH0000
author: 
  - "John Student (z123456), "
  - "Jim Student2 (zID), "
  - "Jack Student3 (zID)." 
date: "25/07/2020"
Acknowledgements: 
Abstract: "A first assessed activity will be the Group Project Plan (15%). The first step is to delimit the problem which will be studied. You should understand and define the overall problem and propose a solution. Having only a short time to complete the project, it  is crucial that the problem that will be studied is well defined. The approach to solve the problem should be original, so it will be necessary to carry out a preliminary literature review. This will prevent any plagiarism. This will also enable you to situate the project in a more global context. At this stage, one can identify potential approaches and software that will be used to solve the problem. It is necessary to plan any simulation carefully and to decide what statistical analyses will have to be carried out. All the sub-steps of the project should be planned precisely (a detailed schedule will be created). A kind of short draft version of your final report, consisting of a two-page proposal (excluding the mandatory pages devoted to the title, abstract, contents and references) will be submitted and discussed with one of the instructors at the end of Week 1 or in the beginning of Week 2. Assessment criteria involve the following: a clear definition of the problem; a clear description of the data format and their storage; a clear description of the relevant data (variables, missing and corrupt values, etc.); the level of difficulty of the chosen data sets (size, complexity, messiness) and its relevance for the chosen problem; the appropriate choice of software and statistical methods to solve your research questions; a clear description of the role of each team member with a proper justification; the precision of your scheduled activities."
output:
  pdf_document:
    template: template.tex
    md_extensions: +raw_attribute
    keep_md: true 
    keep_tex: true 
    pandoc_args:
    - --top-level-division="chapter"
    toc: true
    toc_depth: 1
    number_sections: true
---



\setcounter{chapter}{1}
\renewcommand\thesection{\arabic{section}}

## Introduction and Motivation {.label:s-intro}

You should describe the problem in your own words and motivate its importance. Your description should be clear for a reader not familiar with the problem (e.g., a student in your discipline but who is not involved in the course, another professor from your school who is not teaching this course). The idea is that you explain clearly what you have understood about what exactly is the problem after having listened to the project provider, and after potential discussions with the sponsor and/or your lecturers.

\bigskip

Then, briefly describe how you intend to solve the problem (e.g., compare several existing methodologies, apply specific statistical techniques, etc.).

## Brief Literature Review

Survey the most related work you have found in the literature. Due to space restrictions, describe only the most relevant work and discuss its connections to your work. Describe the methods employed in the related work, as well as the employed measure of success.



\bigskip

In order to incorporate your own references in this report, we strongly advise you use BibTeX. Your references then need to be recorded in the file `references.bib`, and cited as follows  \cite{Lafaye2013}. 


## Methods, Software and Data Description

You should describe the techniques you intend to use and why
you have selected these techniques. Also, describe the software and libraries that you will need to implement
your analyses. You can revise this later since this is an initial proposal. Finally, provide a clear description of
the relevant data (format, storage, variables, messiness, size, complexity) and its relevance for the chosen problem.

## Activities and Schedule

List the main project activities and create a timetable for the activities. You can use a Gantt Chart (see next page). Describe the roles of all team members.

\newpage

Here is an example created using \LaTeX:


\definecolor{barblue}{RGB}{153,204,254}
\definecolor{groupblue}{RGB}{51,102,254}
\definecolor{linkred}{RGB}{165,0,33}
\renewcommand\sfdefault{phv}
\renewcommand\mddefault{mc}
\renewcommand\bfdefault{bc}
\setganttlinklabel{s-s}{START-TO-START}
\setganttlinklabel{f-s}{FINISH-TO-START}
\setganttlinklabel{f-f}{FINISH-TO-FINISH}
\sffamily
\begin{ganttchart}[
    canvas/.append style={fill=none, draw=black!5, line width=.75pt},
    hgrid style/.style={draw=black!5, line width=.75pt},
    vgrid={*1{draw=black!5, line width=.75pt}},
    today=7,
    today rule/.style={
      draw=black!64,
      dash pattern=on 3.5pt off 4.5pt,
      line width=1.5pt
    },
    today label font=\small\bfseries,
    title/.style={draw=none, fill=none},
    title label font=\bfseries\footnotesize,
    title label node/.append style={below=7pt},
    include title in canvas=false,
    bar label font=\mdseries\small\color{black!70},
    bar label node/.append style={left=2cm},
    bar/.append style={draw=none, fill=black!63},
    bar incomplete/.append style={fill=barblue},
    bar progress label font=\mdseries\footnotesize\color{black!70},
    group incomplete/.append style={fill=groupblue},
    group left shift=0,
    group right shift=0,
    group height=.5,
    group peaks tip position=0,
    group label node/.append style={left=.6cm},
    group progress label font=\bfseries\small,
    link/.style={-latex, line width=1.5pt, linkred},
    link label font=\scriptsize\bfseries,
    link label node/.append style={below left=-2pt and 0pt}
  ]{1}{13}
  \gantttitle[
    title label node/.append style={below left=7pt and -3pt}
  ]{WEEKS:\quad1}{1}
  \gantttitlelist{2,...,13}{1} \\
  \ganttgroup[progress=57]{WBS 1 Summary Element 1}{1}{10} \\
  \ganttbar[
    progress=75,
    name=WBS1A
  ]{\textbf{WBS 1.1} Activity A}{1}{8} \\
  \ganttbar[
    progress=67,
    name=WBS1B
  ]{\textbf{WBS 1.2} Activity B}{1}{3} \\
  \ganttbar[
    progress=50,
    name=WBS1C
  ]{\textbf{WBS 1.3} Activity C}{4}{10} \\
  \ganttbar[
    progress=0,
    name=WBS1D
  ]{\textbf{WBS 1.4} Activity D}{4}{10} \\[grid]
  \ganttgroup[progress=0]{WBS 2 Summary Element 2}{4}{10} \\
  \ganttbar[progress=0]{\textbf{WBS 2.1} Activity E}{4}{5} \\
  \ganttbar[progress=0]{\textbf{WBS 2.2} Activity F}{6}{8} \\
  \ganttbar[progress=0]{\textbf{WBS 2.3} Activity G}{9}{10}
  \ganttlink[link type=s-s]{WBS1A}{WBS1B}
  \ganttlink[link type=f-s]{WBS1B}{WBS1C}
  \ganttlink[
    link type=f-f,
    link label node/.append style=left
  ]{WBS1C}{WBS1D}
\end{ganttchart}

\bigskip

Here is an example created using R:

![](unsw-ZZSC9020-Project-Plan-template_files/figure-latex/unnamed-chunk-1-1.pdf)<!-- --> 


<!---
# References
-->

\bibliographystyle{elsarticle-num}
\bibliography{references}


